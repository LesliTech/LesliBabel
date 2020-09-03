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
import componentStringEditorModuleBucket from "../components/string-editor-module-bucket.vue"
import componentStringEditor from "../components/string-editor.vue"


// · 
export default {
    components: {
        "component-string-editor-module-bucket": componentStringEditorModuleBucket,
        "component-string-editor": componentStringEditor
    },
    data() {
        return {
            loading: false,
            bucket: {},
            modules: [],
            moduleBuckets: [],
            selection: { module: null, bucket: null },
            missingTranslations: {},
            searchStrings: null,
            options: {}
        }
    },
    mounted() {
        this.getModules()
        this.getMissingTranslationStrings()
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

        getMissingTranslationStrings() {
           
            this.missingTranslations= {}
            this.http.get("/babel/translation/strings.json?perPage=100").then(result => {
                this.missingTranslations = {
                    total: result.data.total,
                    strings: result.data.data
                }
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

        getSearch(search) {

            if (search == "") {
                this.searchStrings = null
                return
            }

            this.http.get("/babel/translation/search.json?label="+search).then(result => {
                this.searchStrings = result.data
            }).catch(error => {
                console.log(error)
            })

        },

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
            </div>
        </component-header>

        <component-toolbar @search="getSearch">
        </component-toolbar>

        <!-- String editor for search results -->
        <component-string-editor v-if="searchStrings" :strings="searchStrings" :showPath="true">
        </component-string-editor>

        <!-- String editor for missing translation strings -->
        <template v-if="!searchStrings && !selection.module && missingTranslations.total > 0">
            <br>
            <component-header subtitle="Relevant translations">
            </component-header>
            <component-string-editor 
                :strings="missingTranslations.strings" 
                :showPath="true">
            </component-string-editor>
        </template>

    </section>
</template>
