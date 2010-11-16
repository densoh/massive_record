module MassiveRecord
  
  class Scanner
    
    attr_accessor :connection, :table_name, :column_families_names, :opened_scanner
    
    def initialize(connection, table_name, column_families_names)
      @connection = connection
      @table_name = table_name
      @column_families_names = column_families_names.collect{|n| "#{n.split(":").first}:"}
    end
    
    def client
      connection.client
    end
    
    def open
      begin
        @opened_scanner ||= client.scannerOpen(table_name, "", column_families_names)
        true
      rescue => e
        false
      end
    end
    
    def fetch_trows(opts = {})
      opts[:limit] ||= 10
      client.scannerGetList(opened_scanner, opts[:limit])
    end
    
    def fetch_rows(opts = {})
      populate_rows(fetch_trows(opts))
    end
    
    def populate_rows(results)
      results.collect{|result| populate_row(result)}
    end
    
    def populate_row(result)
      MassiveRecord::Row.populate_from_t_row_result(result)
    end
    
  end
  
end