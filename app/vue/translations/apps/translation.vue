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
import componentStringEditor from "../components/strings-editor.vue"


// · 
export default {
    components: {
        'component-string-editor': componentStringEditor
    },
    data() {
        return {
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
        }

    },
    watch: {

        // triggers after Select Module
        'selection.module': function() {
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
    <section class="section">
        <div class="card box">
            <div class="card-header">
                <h4 class="card-header-title">
                    Selection
                </h4>
            </div>
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

                </div>
            </div>
        </div>

        <component-string-editor v-if="bucket.id" :module="selection.module" :bucket="bucket" />
        
    </section>
</template>
