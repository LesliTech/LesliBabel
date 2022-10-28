namespace :cloud_babel do
    namespace :fixes do
        namespace :db do
            desc "Truncating all DB tables"
            task truncate_tables!: :environment do
                begin
                    L2.warn("This rake task truncates all DB tables")
    
                    # Go through all tables and look for the ones of CloudBabel
                    ActiveRecord::Base.connection.tables.each do |table|
                        next if table.eql? "schema_migrations"
                        next unless table.starts_with? "cloud_babel_"
    
                        puts "Truncating table #{table}"
                        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE;")
                    end
    
                    L2.success("All tables from CloudBabel were successfully truncated :)")
                rescue => exception
                    L2.danger("SOMETHING WENT WRONG :(")
                    puts exception.message
                end
            end
        end
    end
end