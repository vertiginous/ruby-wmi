require 'win32ole'

module WMI

    def subclasses(options ={})
      Base.set_connection(options)
      b = Base.connection
      b.SubclassesOf.map { |subclass| class_name = subclass.Path_.Class }
    end
    
    alias :subclasses_of :subclasses

    def const_missing(name)
      self.const_set(name, Class.new(self::Base))
    end
    extend self
    
  class Base
      
    class << self
      def subclass_name
        self.name.split('::').last
      end

      def connection
        c = WIN32OLE.new("WbemScripting.SWbemLocator")
        c.ConnectServer(@host,@klass,@credentials[:user],@credentials[:passwd])
      end
      
      def set_connection(options)
        @host = options[:host] || nil
        @klass = options[:class] || 'root/cimv2'
        @credentials = options[:credentials] || {:user => nil,:passwd => nil}
      end
      
      def find_by_wql(query)
        d = connection.ExecQuery(query)
        d.count # needed to check for errors.  Weird, but it works.
        d.to_a
      end

      def find(arg=:all, options={})
        set_connection options
        case arg
          when :all; find_all(options)
          when :first; find_first(options)
        end
      end
      
      def find_first(options={})
        find_all(options).first
      end

      def find_all(options={})
        find_by_wql(construct_finder_sql(options))
      end
      
      def construct_finder_sql(options)
        #~ scope = scope(:find)
        sql  = "SELECT #{options[:select] || '*'} "
        sql << "FROM #{options[:from] || subclass_name} "

        #~ add_joins!(sql, options, scope)
        add_conditions!(sql, options[:conditions], nil)

        sql << " GROUP BY #{options[:group]} " if options[:group]

        #~ add_order!(sql, options[:order], scope)
        #~ add_limit!(sql, options, scope)
        #~ add_lock!(sql, options, scope)

        sql
      end
      
      def add_conditions!(sql, conditions, scope = :auto)
        #~ scope = scope(:find) if :auto == scope
        segments = []
        segments << sanitize_sql(conditions)  unless conditions.nil?
        #~ segments << conditions unless conditions.nil?
        #~ segments << type_condition unless descends_from_active_record?
        segments.compact!
        sql << "WHERE (#{segments.join(") AND (")}) " unless segments.empty?
        sql.gsub!("\\","\\\\\\")
      end
      
      # Accepts an array, hash, or string of sql conditions and sanitizes
      # them into a valid SQL fragment.
      #   ["name='%s' and group_id='%s'", "foo'bar", 4]  returns  "name='foo''bar' and group_id='4'"
      #   { :name => "foo'bar", :group_id => 4 }  returns "name='foo''bar' and group_id='4'"
      #   "name='foo''bar' and group_id='4'" returns "name='foo''bar' and group_id='4'"
      def sanitize_sql(condition)
        case condition
          when Array; sanitize_sql_array(condition)
          when Hash;  sanitize_sql_hash(condition)
          else        condition
        end
      end

      # Sanitizes a hash of attribute/value pairs into SQL conditions.
      #   { :name => "foo'bar", :group_id => 4 }
      #     # => "name='foo''bar' and group_id= 4"
      #   { :status => nil, :group_id => [1,2,3] }
      #     # => "status IS NULL and group_id IN (1,2,3)"
      def sanitize_sql_hash(attrs)
        conditions = attrs.map do |attr, value|
          #~ "#{table_name}.#{connection.quote_column_name(attr)} #{attribute_condition(value)}"
          "#{attr} = '#{value}'"
        end.join(' AND ')

        #~ replace_bind_variables(conditions, attrs.values)
      end 
    end
  end
end
