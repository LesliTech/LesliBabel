module LesliBabel
    class ModuleServices < LesliServices 

        def self.installed_engines_id

            # get the list of installed engines, including: rails_core, rails_builder, rails_engine
            babel_modules_names = Rails.application.config.lesli.dig(:engines).map { |engine| engine[:name] }

            # always include the core
            babel_modules_names.push("Core")

            # get list of ids of installed engines and available third-party apps
            Module
            .where(:name => babel_modules_names) # -> only installed engines
            .or(Module.where.not(:platform => ["rails_core", "rails_builder", "rails_engine"]))
            .map { |engine| engine.id } 
            
        end

    end
end
