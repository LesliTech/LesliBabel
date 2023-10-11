=begin

Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

LesliBabel::Engine.routes.draw do  
    root to: "dashboards#show"
    resource :dashboard

    # working with modules
    resources :modules, only: [:index, :show, :new, :create, :edit] do 
        resources :buckets, only: [:index]
    end

    # working with translations
    resources :translations, only: [:index] do 
        collection do 
            get :options
            post :renovate
            post :deploy 
            post :sync
        end 
    end 

    # relevant strings
    resources :relevants, only: [:index]

    # working with strings
    resources :strings, only: [:index, :create, :update] do 
        collection do 
            get :stats
            get :locales
            get :relevant
        end 
    end 
end
