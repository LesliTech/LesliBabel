/*
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
*/


// · Import Lesli builders
import application from "Lesli/application"
import translation from "Lesli/translation"


// · Import engine translations
import translations from "LesliBabel/stores/translations.json"


// · 
import appDashboardShow from "LesliBabel/apps/dashboards/show.vue"
import appRelevantsIndex from "LesliBabel/apps/relevants/index.vue"
import appTranslationsIndex from "LesliBabel/apps/translations/index.vue"
import appModulesShow from "LesliBabel/apps/modules/show.vue"


// · Buil Lesli translations
translation(translations)


// · 
application("LesliBabel", [{
    path: "/",
    component: appDashboardShow
}, {
    path: "/dashboard",
    component: appDashboardShow
}, {
    path: "/translations",
    component: appTranslationsIndex
}, {
    path: "/relevants",
    component: appRelevantsIndex
}, {
    path: "/modules/:id",
    component: appModulesShow
}])
