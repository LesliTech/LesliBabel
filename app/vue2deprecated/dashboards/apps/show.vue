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


// · import components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentActions from "../../components/actions.vue"
import componentFormLabelEditor from "../../components/form-label-editor.vue"


// · 
export default {
    components: {
        "component-actions": componentActions,
        "component-form-label-editor": componentFormLabelEditor
    },
    data() {
        return {
            searching: false,
            strings: [],
            stats: {},
        }
    },
    mounted() {
        this.getStats()
    },
    methods: {

        getStats() {
            this.http.get("/babel/strings/resources/stats").then(result => {
                if (result.successful) {
                    this.stats = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getSearch(search) {
            this.searching = true
            if (search == "") {
                this.strings = {}
                this.searching = false
                return
            }
            this.http.get("/babel/strings/resources/search.json?search_string="+search).then(result => {
                this.strings = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        showTranslations(locale) {
            this.url.go(`/babel/translations?language=${locale}`)
        },

        flag(localecode) {

            if (localecode == 'en') { return 'flag-icon-gb' }
            if (localecode == 'uk') { return 'flag-icon-ua' }

            return 'flag-icon-'+localecode

        }

    }

}
</script>
<template>
    <section class="application-component">

        <component-header :title="'Registered ' + stats.total_strings + ' labels '">
            <component-actions></component-actions>
        </component-header>

        <component-toolbar @search="getSearch"></component-toolbar>

        <component-form-label-editor v-if="searching" :strings="strings"></component-form-label-editor>

        <template v-if="!searching">
    
            <div class="columns">
                <div class="column" v-for="locale in stats.total_strings_translations" :key="locale.code">
                    <div class="card translations-stats" @click="showTranslations(locale.code)">
                        <div class="card-content has-text-centered">
                            <span :class="['is-size-2','flag-icon', flag(locale.code)]"></span>
                            <p class="is-size-5">
                                {{ locale.name }}: {{ locale.total }}
                            </p>
                            <small>
                                missing: {{ stats.total_strings - locale.total }} translations
                            </small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card mb-3">
                <div class="card-header">
                    <h2 class="card-header-title">
                        {{ stats.total_strings_waiting_for_help }} labels waiting for help
                    </h2>
                </div>
            </div>

            <div class="card mb-3">
                <div class="card-header">
                    <h2 class="card-header-title">
                        {{ stats.total_strings_waiting_for_translation }} labels waiting for translation
                    </h2>
                </div>
            </div>

            <div class="card mb-3">
                <div class="card-header">
                    <h2 class="card-header-title">
                        Last synchronization: {{ stats.last_synchronization_at }}
                    </h2>
                </div>
            </div>

        </template>

    </section>
</template>
