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


// · Import main app
import app from "LesliVue/app2"



// · Import apps and components
import dashboard from "./dashboards/apps/show.vue"
import translationShow from "./translations/pages/show.vue"
import moduleIndex from "./modules/apps/index.vue"
import moduleShow from "./modules/apps/show.vue"
import moduleEdit from "./modules/apps/edit.vue"
import moduleNew from "./modules/apps/new.vue"
import cloneShow from "./clones/apps/show.vue"



// · Cloud app
app("CloudBabel", "/babel", "[dashboard|translations|modules|clones]", [{
    path: "/",
    component: dashboard
}, {
    path: "/translations",
    component: translationShow,
}, {     
    path: "/modules",
    component: moduleIndex,
}, {
    path: "/modules/new",
    component: moduleNew,
}, {
    path: "/modules/:id",
    component: moduleShow
}, {
    path: "/modules/:id/edit",
    component: moduleEdit
}, {
    path: "/clone",
    component: cloneShow
}], {
    language: null,
    label: {}
})
