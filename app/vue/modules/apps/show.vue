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
            search_text: '',
            searching: false,
            pagination: {
                per_page: 20,
                count_total: 0,
                current_page: 1,
                range_before: 3,
                range_after: 3,
            },
            strings: {
                records: []
            },
            options: {}
        }
    },
    mounted() {
        this.id = this.$route.params.id
        this.getModule()
        this.getOptions()
        this.getBuckets()
        this.getStrings()
        this.data.label.getStrings = () => this.getStrings()
    },
    methods: {

        setFilterText(search_text){
            this.search_text = search_text
            this.pagination.current_page = 1
            this.getStrings()
        },

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
            let url = `/babel/strings/resources/search.json?search_string=${this.search_text}`
            if(this.id){
                url += `&module_id=${this.id}`
            }
            if(this.bucket && this.bucket.id){
                url += `&bucket_id=${this.bucket.id}`
            }
            url += `&page=${this.pagination.current_page}&perPage=${this.pagination.per_page}`

            this.strings = {
                records: []
            }
            this.loading = true

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.strings = result.data
                    this.pagination.count_total = result.data.pagination.count_total
                }
            }).catch(error => {
                console.error(error)
            }).finally(() => {
                this.loading = false
            })
           
        }

    },

    watch: {

        bucket: function() {
            this.getStrings()
        },

        'pagination.current_page': function() {
            if (!this.loading) {
                this.getStrings()
            }
        },

        'pagination.per_page': function() {
            if (!this.loading) {
                this.pagination.current_page = 1
                this.getStrings()
            }
        },

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

        <component-toolbar @search="setFilterText">
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


        <div class="card">
            <div class="card-content">

                <component-data-loading v-if="loading" />
                <component-data-empty v-if="!loading && strings.records.length == 0" />

                <div v-if="!loading && strings.records.length > 0">
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
                </div>
            </div>
        </div>

    </section>
</template>
