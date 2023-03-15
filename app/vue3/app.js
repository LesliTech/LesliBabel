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
import app from "LesliVue/app"


// · 
import appDashboardShow from "CloudBabel/apps/dashboards/show.vue"
import appRelevantsIndex from "CloudBabel/apps/relevants/index.vue"
import appTranslationsIndex from "CloudBabel/apps/translations/index.vue"
import appModulesShow from "CloudBabel/apps/modules/show.vue"


// · 
app("CloudBabel", [{
    path: "/",
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
