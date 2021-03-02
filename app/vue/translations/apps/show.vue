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
                per_page: 20,
                count_total: 0,
                current_page: 1,
                range_before: 3,
                range_after: 3,
            },
            strings: [],
            options: {},
            availableLocales: {}
        }
    },
    mounted() {
        this.defineLanguage()
        this.getOptions()
        this.getAvailableLocales()
        this.getRelevantStrings()
    },
    methods: {

        defineLanguage() {
            if (this.$route.query.language) {
                this.data.language = this.$route.query.language
            }
        },

        getAvailableLocales() {
            const url = `/babel/strings/resources/available_locales.json`

            this.http.get(url).then(result => {
                if (!result.successful) return
                this.availableLocales = result.data
            }).catch(error => {
                console.error(error)
            }).finally(() => {
                this.loading = false
            })
        },

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

            let url = `/babel/strings/resources/relevant.json?page=${this.pagination.current_page}&perPage=${this.pagination.per_page}`

            if (this.data.language) {
                url += `&language=${this.data.language}`
            }

            this.http.get(url).then(result => {
                if (!result.successful) return
                this.strings = result.data
                this.pagination.count_total = result.data.pagination.count_total
                this.pagination.current_page = result.data.pagination.current_page
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

    },

    watch: {

        'pagination.current_page': function() {
            if (!this.loading) {
                this.getRelevantStrings()
            }
        },

        'pagination.per_page': function() {
            if (!this.loading) {
                this.pagination.current_page = 1
                this.getRelevantStrings()
            }
        },

        'data.language': function() {
            if (!this.loading) {
                this.getRelevantStrings()
            }
        },

    },

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
            <div class="control">
                <div class="select">
                    <select v-model="data.language">
                        <option :value="null">All</option>
                        <option v-for="(language, locale) in availableLocales" :key="locale" :value="locale">{{ language }}</option>
                    </select>
                </div>

                <div class="select">
                    <select v-model="pagination.per_page">
                        <option :value="20">20</option>
                        <option :value="50">50</option>
                        <option :value="75">75</option>
                        <option :value="100">100</option>
                    </select>
                </div>
            </div>
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

        <b-pagination
            :simple="false"
            :total="pagination.count_total"
            :current.sync="pagination.current_page"
            :range-before="pagination.range_before"
            :range-after="pagination.range_after"
            :per-page="pagination.per_page"
            order="is-centered"
            icon-prev="chevron-left"
            icon-next="chevron-right"
            aria-next-label="Next page"
            aria-previous-label="Previous page"
            aria-page-label="Page"
            aria-current-label="Current page">
        </b-pagination>
        
    </section>
</template>
