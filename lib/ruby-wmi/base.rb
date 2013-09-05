module RubyWMI
  # Many of the methods in Base are borrowed directly, or with some modification from ActiveRecord
  #   http://api.rubyonrails.org/classes/ActiveRecord/Base.html
  class Base
    class << self    
      # #find_by_wql currently only works when called through #find
      # it may stay like that too.  I haven't decided.
      def find_by_wql(query)
        # TODO: add logging, ie:
        logger.debug query if logger
        d = connection.ExecQuery(query)
        begin
          d.count # needed to check for errors.  Weird, but it works.
        rescue => error
          case error.to_s
          when /Invalid class/i
            raise InvalidClass
          when /Invalid query/i
            raise InvalidQuery
          when /Invalid namespace/i
            raise InvalidNameSpace            
          end
        end
        clear_connection_options
        d.map{|wmi_object| new(wmi_object) }
      end

      #  WMI::Win32_ComputerSystem.find(:all)
      #    returns an array of Win32ComputerSystem objects
      #
      #  WMI::Win32_ComputerSystem.find(:first)
      #    returns the first Win32_ComputerSystem object
      #
      #  WMI::Win32_ComputerSystem.find(:last)
      #    returns the last Win32_ComputerSystem object
      #
      #  options:
      #
      #    :conditions
      #
      #     Conditions can either be specified as a string, array, or hash representing the WHERE-part of an SQL statement.
      #     The array form is to be used when the condition input is tainted and requires sanitization. The string form can
      #     be used for statements that don't involve tainted data. The hash form works much like the array form.
      #
      #       Hash examples:
      #
      #         WMI::Win32_ComputerSystem.find(:all, :conditions => {:drive_type => 3} )
      #         WMI::Win32_NTLogEvent.find(:all, :conditions => {:time_written => time_range})
      #
      #       Array examples:
      #
      #         WMI::Win32_ComputerSystem.find(:all, :conditions => ['DriveType = ?', 3] )
      #         WMI::Win32_Service.all(:conditions => ["StartMode = ? AND Started = ?", 'manual', true])
      #         WMI::Win32_Process.all(:conditions => ["Name LIKE  %s", 'G%'])
      #
      #       String example:
      #
      #         WMI::Win32_ComputerSystem.find(:all, :conditions => 'DriveType = 3' )
      #
      #    :select
      #      By default, this is "*" as in "SELECT * FROM", but can be changed.
      #      Takes a string or symbol with a single column (e.g. "id"), or an array with 
      #      multiple columns, (e.g. [:start_mode, :start_name, :status] )
      #      Column names are converted from underscore to camelcase, so :start_mode
      #      becomes StartMode
      #
      #    :host       - computername, defaults to localhost
      #    :namespace  - swebm namespace , defaults to 'root\\cimv2'
      #    :privileges - see WMI::Privilege for a list of privileges
      #    :user       - username (domain\\username)
      #    :password   - password
      def find(arg=:all, options={})
        set_connection options
        case arg
        when :all
          find_all(options)
        when :first
          find_first(options)
        when :last
          find_last(options)
        when String
          options.merge!(:conditions => { :name => arg })
          find_first(options)
        end
      end

      # an alias for find(:last)      
      def last(options={})
        find(:last, options)
      end
      
      # an alias for find(:first)      
      def first(options={})
        find(:first, options)
      end
      
      # an alias for find(:all)
      def all(options={})
        find(:all, options)
      end

      def count(options={})
        find(:all, options).size
      end
      
      def method_missing(method_id, *arguments)
        if match = /find_(all_by|by)_([_a-zA-Z]\w*)/.match(method_id.to_s)
          case match[1]
          when 'all_by'
            conditions = match[2].split('_and_').zip(arguments)
            conditions = Hash[*conditions.flatten]
            all(:conditions => conditions)
          when 'by'
            first(:conditions => {match[2] => arguments.first})
          end          
        else
          super
        end
      end


      def set_connection(options={})
        @host       = options[:host].to_s    || connection_options[:host].to_s
        @user       = options[:user]         || connection_options[:user]
        @password   = options[:password]     || connection_options[:password]
        @namespace  = options[:namespace]    || self.namespace 
        @privileges = options[:privileges]
      end
      
      def clear_connection_options
        @host       = nil
        @user       = nil
        @password   = nil
        @namespace  = nil
        @privileges = nil
        connection_options.clear
      end
      
      def set_wmi_class_name(name)
        @subclass_name = name
      end
      
      def set_wmi_namespace(namespace)
        @namespace_ = namespace
      end

      def namespace
        @namespace_ ||= 'root\\cimv2'
      end

      def subclass_name
        @subclass_name ||= self.name.split('::').last
      end
      
      def host(hostname)
        connection_options[:host] = hostname.to_s
        self
      end
      
      def connection_options
        @connection_options ||= {}
      end
    
      def columns
        @columns ||= first(:from => 'meta_class', :conditions => "__this ISA '#{subclass_name}'").attribute_names
      end
        
      def writable?(key)
        obj_def = connection.get(subclass_name)
        key = camelize(key)
        key_prop = obj_def.properties_(key)
        key_prop.qualifiers_.each do |q|
          return true if q.name == 'write'
        end
        false
      end
      
      def logger
        @@logger ||= nil
      end
      
      def logger=(logger)
        @@logger = logger
      end

      private

        def connection
          @c ||= WIN32OLE.new("WbemScripting.SWbemLocator")
          @privileges.each { |priv| @c.security_.privileges.add(priv, true) } if @privileges
          log_connection if logger
          @c.ConnectServer(@host,@namespace,@user,@password)
        end
        
        # logs SWbemLocator.ConnectServer parameters
        # default parameters aren't logged.
        def log_connection
          msg =  ""
          msg <<  "Host: #{@host.inspect}, "              unless @host.empty?
          msg << "Namespace: #{@namespace.inspect}, "     unless @namespace == "root\\cimv2" && @host.empty?
          msg << "User: #{@user.inspect}, "               if @user
          msg << "Password: #{@password.gsub(/./,'#')}, " if @password
          msg << "Privileges: #{@privileges.inspect}"     if @privileges
          logger.debug msg unless msg.empty?
        end

        def find_first(options={})
          find_all(options).first
        end
        
        def find_last(options={})
          find_all(options).last
        end

        def find_all(options={})
          find_by_wql(construct_finder_sql(options))
        end

        def construct_finder_sql(options)
          [
            select(options[:select]),
            from(options[:from]),
            conditions(options[:conditions], nil),
            group(options[:group])
           ].compact.join(' ')
        end
        
        def select(*selectors)
          selectors = selectors.compact.empty? ? '*' : selectors.flatten.map{|i| camelize(i) }.join(', ')
          "SELECT #{selectors}"
        end
        
        def from(wmi_class)
          "FROM #{wmi_class || subclass_name}"
        end

        def conditions(conditions, scope = :auto)
          segments = []
          segments << sanitize_sql(conditions) unless conditions.nil?
          segments.compact!
          "WHERE #{segments.join(") AND (")}".gsub(/\\/, '\&\&') unless segments.empty?
        end
        
        def group(items)
          "GROUP BY #{items}" if items
        end

        # Accepts an array, hash, or string of sql conditions and sanitizes
        # them into a valid SQL fragment.
        #   ["name='%s' and device_id='%s'", "foo'bar", 4]  returns  "name='foo''bar' AND DeviceId='4'"
        #   { :name => "foo'bar", :device_id => 4 }  returns "name='foo''bar' AND DeviceId='4'"
        #   "name='foo''bar' AND DeviceId='4'" returns "name='foo''bar' AND DeviceId='4'"
        def sanitize_sql(condition)
          case condition
            when Array
              sanitize_sql_array(condition)
            when Hash
              sanitize_sql_hash(condition)
            else        condition
          end
        end

        # Sanitizes a hash of attribute/value pairs into SQL conditions.
        #   { :name => "foo'bar", :device_id => 4 }
        #     # => "name='foo''bar' AND DeviceId= 4"
        #   { :status => nil, :device_id => [1,2,3] }
        #     # => "status IS NULL AND DeviceId = '1' OR DeviceId = '2' OR DeviceId = '3'"
        def sanitize_sql_hash(attrs)
          conditions = attrs.map do |attr, value|
            attribute_condition(camelize(attr), value)
          end.join(' AND ')
          replace_bind_variables(conditions, expand_range_bind_variables(attrs.values))
        end
        
        def sanitize_sql_array(ary)
          statement, *values = ary
          if values.first.is_a?(Hash) and statement =~ /:\w+/
            replace_named_bind_variables(statement, values.first)
          elsif statement.include?('?')
            replace_bind_variables(statement, values)
          else
            statement % values.collect { |value| "'#{value}'" }
          end
        end 
        
        def replace_bind_variables(statement, values) #:nodoc:
          raise WMIError.new("Mismatched arity #{statement}:#{values.inspect}") unless statement.count('?') == values.size
          bound = values.dup
          statement.gsub('?') { quote(bound.shift) }
        end
        
        def attribute_condition(column_name, argument)
          case argument
            when nil   then "#{column_name} IS ?"
            when Array then argument.map{|a| "#{column_name} = ? "}.join(" OR ")
            when Range then if argument.exclude_end?
                              "#{column_name} >= ? AND #{column_name} < ?"
                            else
                              "#{column_name} >= ? AND #{column_name} <= ?"
                            end
            else           
              "#{column_name} = ?"
          end
        end
        
        def expand_range_bind_variables(bind_vars)
          expanded = []

          bind_vars.each do |var|
            next if var.is_a?(Hash)

            if var.is_a?(Range)
              expanded << var.first
              expanded << var.last
            elsif var.is_a?(Array)
              expanded = var
            else
              expanded << var
            end
          end

          expanded
        end
        
        def quote(item)
          case item
            when NilClass
              "NULL" 
            when Time
              "'#{item.to_swbem_date_time}'"
            else  
              "'#{item}'"
          end
        end
           
        def camelize(string)
          string.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }    
        end  
        
        def underscore(string)
          string.to_s.gsub(/::/, '/').gsub('_', '___').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
        end
    end

    def initialize(win32ole_object)
      @win32ole_object = win32ole_object
    end
    
    def methods(all_methods=true)
      super(all_methods) + @win32ole_object.methods_.map{|method| underscore(method.name) }
    end
    
    def attributes
      if @attributes
        return @attributes
      else
        @attributes = {}
        @win32ole_object.properties_.each{ |prop| 
          name  = prop.name
          value = @win32ole_object.send(name)
          value = if prop.cimtype == 101 && value
            Time.parse_swbem_date_time(value) 
          else
            value
          end
          @attributes[underscore(name)] = value
        }
        return @attributes
      end
    end
    
    def attribute_names
      @attribute_names ||= @win32ole_object.properties_.map{ |p| underscore(p.name) }
    end
    
    def [](key)
      key = camelize(key.to_s)
      @win32ole_object[key] 
    end
    
    def []=(key,value)
      key = camelize(key.to_s)
      raise ReadOnlyError unless writable?(key)
      @win32ole_object[key] = value
      @win32ole_object.Put_
    end
    
    def method_missing(name,*args)
      name = camelize(name.to_s)
      @win32ole_object.send(name, *args)
    end
    
    def camelize(string)
      self.class.send(:camelize, string)
    end  
    
    def underscore(string)
      self.class.send(:underscore, string)
    end
    
    def inspect
      "#<#{self.class}:#{name}>"
    end

    def name
      @win32ole_object.name 
    rescue
      begin
        @win32ole_object.description
      rescue
        object_id
      end
    end
  end
end
