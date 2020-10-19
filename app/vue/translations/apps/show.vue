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


// · Components
import componentFormLabelEditor from "../../components/form-label-editor.vue"
import componentActions from "../../components/actions.vue"


// · 
export default {
    components: {
        "component-actions": componentActions,
        "component-form-label-editor": componentFormLabelEditor
    },
    data() {
        return {
            id: null,
            module: {},
            bucket: null,
            buckets: [],
            loading: false,
            searching: false,
            pagination: {
                per_page: 15,
                total_count: 0,
                current_page: 1,
                range_before: 3,
                range_after: 3,
            },
            strings: [],
            options: {}
        }
    },
    mounted() {
        this.getOptions()
        this.getRelevantStrings()
    },
    methods: {

        getOptions() {

            this.options = {}
            this.http.get("/babel/translations/options.json").then(result => {
                this.options = result.data
            }).catch(error => {
                console.log(error)
            })

        },

        getRelevantStrings() {
            this.strings = []
            this.loading = true

            this.http.get("/babel/strings.json?page=1&perPage=50").then(result => {
                if (!result.successful) return 
                this.strings = result.data
                this.pagination = result.data.pagination
            }).catch(error => {
                console.error(error)
            }).finally(() => {
                this.loading = false
            })
           
        },

        getSearch(search) {
            this.searching = true
            if (search == "") {
                this.strings = {}
                this.searching = false
                this.getRelevantStrings()
                return
            }
            this.http.get("/babel/strings/resources/search.json?search_string="+search).then(result => {
                this.strings = result.data
            }).catch(error => {
                console.log(error)
            })
        }

    }

}
</script>
<template>
    <section class="application-component">
        <component-header title="Relevant translations">
            <div class="buttons">
                <component-actions :all_actions="true" :module_id="id"></component-actions>
            </div>
        </component-header>

        <component-toolbar @search="getSearch">
        </component-toolbar>

        <component-form-label-new
            v-if="bucket" 
            :module="this.module" 
            :bucket="this.bucket">
        </component-form-label-new>

        <component-form-label-editor
            :strings="strings"
            :options="options"
            :pagination="pagination">
        </component-form-label-editor>
        
    </section>
</template>
