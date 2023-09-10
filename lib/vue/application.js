/*
Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · 
import application from "Lesli/application"


// · 
import appDashboardShow from "LesliBabel/apps/dashboards/show.vue"
import appRelevantsIndex from "LesliBabel/apps/relevants/index.vue"
import appTranslationsIndex from "LesliBabel/apps/translations/index.vue"
import appModulesShow from "LesliBabel/apps/modules/show.vue"


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
