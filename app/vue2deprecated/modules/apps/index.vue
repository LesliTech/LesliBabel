<script>
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



// · import components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


// · 
export default {
    data() {
        return {
            columns: [{
                field: "id",
                label: "ID",
                width: "40"
            }, {
                field: "name",
                label: "Name",
            }, {
                field: "platform",
                label: "Type",
            }],
            modules: []
        }
    },
    mounted() {
        this.getModules()
    },
    methods: {

        getModules() {
            this.http.get("/babel/modules.json").then(result => {
                this.modules = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        showModule(module) {
            this.$router.push(`/babel/modules/${module.id}`)
        },

        editModule(module) {
            this.$router.push(`/babel/modules/${module.id}/edit`)
        }

    }
}
</script>
<template>
    <section class="application-component">
        <component-header title="Modules & devices">
            <div class="is-grouped">
                <router-link class="button" to="/babel/modules/new">
                    <span class="icon">
                        <i class="fas fa-plus"></i>
                    </span>
                    <span>Add new module or device</span>
                </router-link>
            </div>
        </component-header>
        <div class="card">
            <div class="card-content">
                <b-table 
                    @click="showModule"
                    :data="modules" 
                    :columns="columns">
                </b-table>
            </div>
        </div>
    </section>
</template>
