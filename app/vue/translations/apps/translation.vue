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
            searchStrings: null
        }
    },
    mounted() {
        this.getModules()
        this.getMissingTranslationStrings()
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

        getModuleBuckets() {
            this.http.get(`/babel/translation/modules/${this.selection.module.id}/buckets.json`).then(result => {
                if (!result.successful) return 
                this.moduleBuckets = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        doBackupSync() {
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

        sendPathToClipboard() {

            let path = [this.selection.module.name, this.selection.bucket.name].join(".")

            path = path.toLowerCase()

            const el = document.createElement("textarea");
            el.value = path
            el.setAttribute("readonly", "");
            el.style.position = "absolute";
            el.style.left = "-9999px";
            document.body.appendChild(el);
            el.select();
            document.execCommand("copy");
            document.body.removeChild(el);
            this.alert("Copied to clipboard")

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
                <button class="button" @click="doBackupSync()">
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

        <!-- String editor for module/bucket strings -->
        <template v-if="!searchStrings">
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
            <component-string-editor-module-bucket 
                v-if="selection.module" 
                :module="selection.module" 
                :bucket="bucket">
            </component-string-editor-module-bucket>
        </template>

        <!-- String editor for missing translation strings -->
        <template v-if="!searchStrings && !selection.module && missingTranslations.total > 0">
            <br>
            <component-header subtitle="Missing or needed translations">
            </component-header>
            <component-string-editor 
                :strings="missingTranslations.strings" 
                :showPath="true">
            </component-string-editor>
        </template>
    </section>
</template>
