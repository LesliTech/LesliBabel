=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "cloud_babel/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|

    spec.name        = "cloud_babel"
    spec.version     = CloudBabel::VERSION
    spec.authors     = ["LesliTech"]
    spec.email       = ["hello@lesli.tech"]
    spec.homepage    = "https://lesli.cloud"
    spec.summary     = "Translation management for LesliCloud"
    spec.license     = "All rights reserved"

    spec.files = Dir["{app,config,db,lib}/**/*", "license", "Rakefile", "readme.md"]

    spec.add_dependency "rails", "~> 6.0.0"

end
