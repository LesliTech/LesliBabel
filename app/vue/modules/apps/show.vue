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
import componentFormLabelNew from "../../components/form-label-new.vue"
import componentActions from "../../components/actions.vue"


// · 
export default {
    components: {
        "component-actions": componentActions,
        "component-form-label-new": componentFormLabelNew,
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
        this.id = this.$route.params.id
        this.getModule()
        this.getOptions()
        this.getBuckets()
        this.getStrings()
    },
    methods: {

        getModule() {
            this.http.get(`/babel/modules/${this.id}.json`).then(result => {
                this.module = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getBuckets() {
            this.http.get(`/babel/modules/${this.id}/buckets.json`).then(result => {
                this.buckets = result.data
            }).catch(error => {
                console.log(error)
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

        getStrings() {
            this.strings = []
            this.loading = true

            // get strings for module (default)
            let url = `/babel/modules/${this.id}/strings.json`

            // if user selects bucket
            if (this.bucket) {
                url = `/babel/modules/${this.id}/buckets/${this.bucket.id}/strings.json`
            }

            //url += `?page=${this.pagination.current_page}&perPage=${this.pagination.per_page}`
            url += `?page=${this.pagination.current_page}&perPage=15`

            this.http.get(url).then(result => {
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
                this.getStrings()
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

        bucket: function() {
            this.getStrings()
        }

    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="module.name">
            <div class="buttons">
                <b-select 
                    class="mr-2"
                    icon="box"
                    icon-pack="fas"
                    placeholder="Select a bucket" 
                    v-model="bucket">
                    <option v-for="bucket in buckets" :key="bucket.id" :value="bucket">
                        {{ bucket.name }}
                    </option>
                </b-select>
                <component-actions :all_actions="true" :module_id="id"></component-actions>
                <router-link :to="`/${id}/edit`" class="button is-primary ml-3">
                    <span class="icon">
                        <i class="far fa-edit"></i>
                    </span>
                </router-link>
            </div>
        </component-header>

        <component-toolbar @search="getSearch">
            <div class="control">
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
            :per-page="pagination.per_page"
            :range-before="5"
            :range-after="5"
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
