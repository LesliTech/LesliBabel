<script>
/*
Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

Lesli - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  <hello@lesli.tech>
@website  <https://lesli.tech>
@license  Propietary - all rights reserved.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/



// · import components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentFormLabelNew from "../components/form-label-new.vue"
import componentFormLabelEditor from "../components/form-label-editor.vue"
import componentQuickView from "../components/quickview.vue"


// · 
export default {
    components: {
        "component-form-label-new": componentFormLabelNew,
        "component-form-label-editor": componentFormLabelEditor,
        "component-quickview": componentQuickView
    },
    data() {
        return {
            loading: false,
            searching: false,
            bucket: {},
            modules: [],
            moduleBuckets: [],
            selection: { module: null, bucket: null },
            strings: {},
            searchString: null,
            options: {},
            pagination: {
                per_page: 10,
                total_count: 0,
                current_page: 1,
                range_before: 3,
                range_after: 3,
            },
            show_quickview: false,
            selected_string_id: null
        }
    },
    beforeDestroy(){
        this.deleteSubscriptions()
    },
    mounted() {
        this.getModules()
        this.getRelevantStrings()
        this.getOptions()
        this.setSubscriptions()
    },
    methods: {
        deleteSubscriptions(){
            this.bus.$off('post:/babel/translation/strings.json')
        },

        setSubscriptions(){
            this.bus.subscribe('post:/babel/translation/strings.json', () => {
                this.reloadData()
            })
        },

        getModules() {
            this.http.get("/babel/modules.json").then(result => {
                if (!result.successful) return 
                this.modules = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getModuleBuckets() {
            this.http.get(`/babel/modules/${this.selection.module.id}/buckets.json`).then(result => {
                if (!result.successful) return 
                this.moduleBuckets = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getRelevantStrings() {
            this.missingTranslations= {}
            this.http.get(`/babel/strings.json?page=${this.pagination.current_page}&perPage=${this.pagination.per_page}`).then(result => {
                this.strings = result.data
                this.setTotalCount(result.data.pagination.count_total)
            }).catch(error => {
                console.log(error)
            })

        },

        getModuleBucketStrings() {
            this.strings = {}
            this.loading = true

            // get strings for module (default)
            let url = `/babel/modules/${this.selection.module.id}/strings.json`

            // if user selects bucket
            if (this.bucket.id) {
                url = `/babel/modules/${this.selection.module.id}/buckets/${this.selection.bucket.id}/strings.json`
            }

            url += `?page=${this.pagination.current_page}&perPage=${this.pagination.per_page}`

            this.http.get(url).then(result => {
                if (!result.successful) return 
                this.strings = result.data
                this.setTotalCount(result.data.pagination.count_total)
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

        getSearch(search) {
            this.searching = true
            if (search == "") {
                this.strings = {}
                this.getRelevantTranslations()
                this.searching = false
                return
            }

            this.http.get("/babel/translation/search.json?search_string="+search).then(result => {
                this.strings = result.data
                this.setTotalCount(result.data.pagination.count_total)
            }).catch(error => {
                console.log(error)
            })

        },



        postSync() {
            this.loading = true
            this.http.post("/babel/translations/resources/synchronization.json").then(result => {
                if (!result.successful) {
                    this.alert("Error", "danger")
                    return 
                }
                this.getModules()
                this.alert("Synchronization successfully")
                this.loading = false
            }).catch(error => {
                console.log(error)
            })
        },

        postDeploy() {
            this.loading = true
            this.http.post("/babel/translation/resources/deploy.json").then(result => {
                if (!result.successful) { this.alert("Error", "danger")}
                this.alert("Translations deploy process done successfully")
                this.loading = false
            }).catch(error => {
                console.log(error)
            })
        },

        getDownloadTranslation() {
            
        },

        reloadData(){
            if (this.selection.module) {
                this.getModuleBucketStrings()
            } else {
                this.getRelevantTranslations()
            }
        },
        
        setTotalCount(count_total){
            this.pagination.total_count = count_total ? 
                            count_total : 
                            0
        },

        quickviewToggleFunction(){
            this.show_quickview = ! this.show_quickview
        }

    },
    watch: {

        // triggers after Select Module
        "selection.module": function() {
            this.selection.bucket = {}
            this.getModuleBuckets()
        },

        // triggers after Select object
        "selection.bucket": function() {
            this.bucket = this.selection.bucket
            this.getModuleBucketStrings()
        },

        'pagination.current_page'(){
            this.reloadData()
        },

        'pagination.per_page'(){
            this.reloadData()
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-quickview
            :show="show_quickview"
            :toggleFunction="quickviewToggleFunction"
            :stringId="selected_string_id"
        >
        </component-quickview>
        <component-header title="Translations">
            <div class="is-grouped">
                <button class="button" @click="postDeploy()">
                    <b-icon icon="rocket" size="is-small" :custom-class="loading ? 'fa-spin' : ''" />
                    <span>deploy translations</span>
                </button>
                <button class="button" @click="postSync()">
                    <b-icon icon="sync" size="is-small" :custom-class="loading ? 'fa-spin' : ''" />
                    <span>synchronize</span>
                </button>

                <template v-if="selection.module">
                    <button 
                        class="button" 
                        v-if="selection.module.type == 'android'"
                        @click="getDownloadTranslation()">
                        <span class="icon">
                            <i class="fab fa-android"></i>
                        </span>
                        <span>download Android translations</span>
                    </button>
                    <button 
                        class="button" 
                        v-if="selection.module.type == 'ios'"
                        @click="getDownloadTranslation()">
                        <span class="icon">
                            <i class="fab fa-swift"></i>
                        </span>
                        <span>download iOS translations</span>
                    </button>
                </template>
            </div>
        </component-header>

        <component-toolbar @search="getSearch">
            <div class="control">
                <div class="select">
                    <select v-model="pagination.per_page">
                        <option :value="10">10</option>
                        <option :value="15">15</option>
                        <option :value="30">30</option>
                        <option :value="50">50</option>
                    </select>
                </div>
            </div>
        </component-toolbar>

        <!-- Module/bucket selector -->
        <template v-if="!searching">
            <div class="card">
                <div class="card-content">
                    <div class="field is-grouped">

                        <div class="control">
                            <b-select
                                placeholder="Select module"
                                icon="globe"
                                icon-pack="fas"
                                v-model="selection.module">
                                <option v-for="module in modules" :key="module.id" :value="module">{{ module.name.replace("Cloud", "") }}</option>
                            </b-select>
                        </div>

                        <div class="control">
                            <b-select
                                placeholder="Select object"
                                icon="globe"
                                icon-pack="fas"
                                v-model="selection.bucket">
                                <option v-for="bucket in moduleBuckets" :key="bucket.id" :value="bucket">{{ bucket.name }}</option>
                            </b-select>
                        </div>

                        <div class="control" v-if="selection.module && selection.bucket && selection.bucket.id">
                            <button class="button is-text" @click="sendPathToClipboard()">
                                <i class="far fa-copy"></i>
                            </button>
                        </div>

                    </div>
                </div>
            </div>
        </template>

        <component-form-label-new
            v-if="selection.module" 
            :module="selection.module" 
            :bucket="bucket">
        </component-form-label-new>
        <br>
        <component-form-label-editor
            :selected-string-id.sync="selected_string_id"
            :strings="strings"
            :options="options"
            :pagination="pagination"
            :quickview-toggle-function="quickviewToggleFunction"
        >
        </component-form-label-editor>
        
        <component-data-loading class="section" v-if="loading"></component-data-loading>
        <component-data-empty v-if="!loading && strings.length == 0"></component-data-empty>

    </section>
</template>
