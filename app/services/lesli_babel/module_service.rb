module LesliBabel
    class ModuleService < Lesli::ApplicationLesliService 

        def find id 
            super(Module.find_by_id(id))
        end

        def list

            # get the list of installed engines, including: rails_core, rails_builder, rails_engine
            babel_modules_names = Lesli::System.engines.map { |engine, engine_info| engine_info[:code] }

            # get list of ids of installed engines and available third-party apps
            Module
            .where(:code => babel_modules_names) # -> only installed engines
            #.or(Module.where.not(:platform => ["rails_core", "rails_builder", "rails_engine"]))
            .map { |engine| engine.id } 
            
        end
    end
end
