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


// · 
export default {
    components: {
        "component-form-label-new": componentFormLabelNew,
        "component-form-label-editor": componentFormLabelEditor
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
            options: {}
        }
    },
    mounted() {
        this.getModules()
        this.getRelevantTranslations()
        this.getOptions()
    },
    methods: {

        getModules() {
            this.http.get("/babel/translation/modules.json").then(result => {
                if (!result.successful) return 
                this.modules = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getRelevantTranslations() {
            this.missingTranslations= {}
            this.http.get("/babel/translation/strings.json?perPage=100").then(result => {
                this.strings = result.data
            }).catch(error => {
                console.log(error)
            })

        },

        getOptions() {

            this.options = {}
            this.http.get("/babel/translation/options.json").then(result => {
                this.options = result.data
            }).catch(error => {
                console.log(error)
            })

        },

        getModuleBuckets() {
            this.http.get(`/babel/translation/modules/${this.selection.module.id}/buckets.json`).then(result => {
                if (!result.successful) return 
                this.moduleBuckets = result.data
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
            }).catch(error => {
                console.log(error)
            })

        },

        getBucketStrings() {

            this.strings = {}
            this.loading = true

            // get strings for module (default)
            let url = `/babel/translation/modules/${this.selection.module.id}/strings.json`

            // if user selects bucket
            if (this.bucket.id) {
                url = `/babel/translation/modules/${this.selection.module.id}/buckets/${this.selection.bucket.id}/strings.json`
            }

            //url += `?page=${this.pagination.current_page}&perPage=${this.pagination.per_page}`

            this.http.get(url).then(result => {
                console.log(result)
                if (!result.successful) return 
                this.strings = result.data
                //this.pagination.count = result.data.total ? result.data.total : 0
            }).catch(error => {
                console.error(error)
            }).finally(() => {
                this.loading = false
            })
           
        },

        postSync() {
            this.loading = true
            this.http.post("/babel/translation/resources/synchronization.json").then(result => {
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
            this.getBucketStrings()
        }

    }
}
</script>
<template>
    <section class="application-component">
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
                <button class="button" @click="getDownloadTranslation()">
                    <b-icon icon="download" size="is-small" :custom-class="loading ? 'fa-spin' : ''" />
                    <span>download translations</span>
                </button>
            </div>
        </component-header>

        <component-toolbar @search="getSearch">
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
                                <option v-for="module in modules" :key="module.id" :value="module">{{ module.name }}</option>
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
            :strings="strings"
            :options="options">
        </component-form-label-editor>
        
        <component-data-loading class="section" v-if="loading"></component-data-loading>
        <component-data-empty v-if="!loading && strings.length == 0"></component-data-empty>

    </section>
</template>
