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

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/



// · import components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentLayoutHeader from "LesliCoreVue/layout/component-header.vue"
import componentStringEditor from "../components/strings-editor.vue"


// · 
export default {
    components: {
        'component-layout-header': componentLayoutHeader,
        'component-string-editor': componentStringEditor
    },
    data() {
        return {
            loading: false,
            bucket: {},
            modules: [],
            moduleBuckets: [],
            selection: { module: null, bucket: null },
            
        }
    },
    mounted() {
        this.getModules()
    },
    methods: {

        getModules() {
            this.http.get('/babel/translation/modules.json').then(result => {
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
            this.http.post(`/babel/translation/synchronization.json`).then(result => {
                if (!result.successful) {
                    this.notification.alert("Error", "danger")
                    return 
                }
                this.getModules()
                this.notification.alert("Synchronization successfully")
                this.loading = false
            }).catch(error => {
                console.log(error)
            })
        },

        postBuild() {
            this.http.post("/babel/translation/build").then(result => {
                if (!result.successful) { this.notification.alert("Error", "danger")}
                this.notification.alert("Translations files built successfully")
                this.notification.alert("Restart Rails to see the new translations")
            }).catch(error => {
                console.log(error)
            })
        },

        sendPathToClipboard() {

            let path = [this.selection.module.name, this.selection.bucket.name].join(".")

            path = path.toLowerCase()

            const el = document.createElement('textarea');
            el.value = path
            el.setAttribute('readonly', '');
            el.style.position = 'absolute';
            el.style.left = '-9999px';
            document.body.appendChild(el);
            el.select();
            document.execCommand('copy');
            document.body.removeChild(el);
            this.notification.alert("Copied to clipboard")

        }

    },
    watch: {

        // triggers after Select Module
        'selection.module': function() {
            this.selection.bucket = {}
            this.getModuleBuckets()
        },

        // triggers after Select object
        'selection.bucket': function() {
            this.bucket = this.selection.bucket
        }

    }
}
</script>
<template>
    <section class="application-component">
        <component-layout-header 
            title="Translations"
            :buttons="false">
            <div class="is-grouped">
                <button class="button" @click="postBuild()">
                    <span class="icon is-small">
                        <i class="fas fa-puzzle-piece"></i>
                    </span>
                    <span>build locales</span>
                </button>
                <button class="button" @click="doBackupSync()">
                    <b-icon icon="sync" size="is-small" :custom-class="loading ? 'fa-spin' : ''" />
                    <span>synchronize</span>
                </button>
            </div>
        </component-layout-header>
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

        <!-- <component-string-editor v-if="bucket.id" :module="selection.module" :bucket="bucket" /> -->
        <component-string-editor v-if="selection.module" :module="selection.module" :bucket="bucket" />
        
    </section>
</template>
