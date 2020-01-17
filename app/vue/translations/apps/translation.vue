<script>
/*
Lesli

Copyright (c) 2019, Lesli Technologies, S. A.

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

@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/

export default {
    data() {
        return {
            modules: [],
            moduleObjects: [],
            moduleObjectTypes: [],
            moduleObjectTypeActions: [],
            

            moduleObjectTypeActionSections: [],
            moduleObjectTypeActionSectionStrings: [],
            selection: { module: null, object: null, obtype: null, action: null, section: null, },
            sharedTranslationString: false,
            timeout: null,
            label: ''
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

        getModuleObjects() {
            this.http.get(`/babel/translation/modules/${this.selection.module.id}/objects.json`).then(result => {
                if (!result.successful) return 
                this.moduleObjects = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getModuleObjectTypes() {
            this.http.get(`/babel/translation/modules/${this.selection.module.id}/objects/${this.selection.object.id}.json`).then(result => {
                if (!result.successful) return 
                this.moduleObjectTypes = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getModuleObjectTypeActions() {
            this.http.get(`/babel/translation/modules/${this.selection.module.id}/objects/${this.selection.obtype.id}.json`).then(result => {
                if (!result.successful) return 
                this.moduleObjectTypeActions = result.data.map(action => {
                    return { 
                        id: action.id, 
                        name: action.name, 
                        object_type: action.type,
                        cloud_babel_translation_objects_id: action.cloud_babel_translation_objects_id, 
                        cloud_babel_translation_modules_id: action.cloud_babel_translation_modules_id,
                        strings: []
                    } 
                })
            }).catch(error => {
                console.log(error)
            })
        },

        getModuleObjectTypeStrings() {
            this.moduleObjectTypeActions.forEach(action => {

                let request = {}

                request = this.http.get(`/babel/translation/modules/${this.selection.module.id}/objects/${action.id}/strings.json`)

                request.then(result => {
                    if (!result.successful) return 
                    action.strings = result.data ? result.data : []
                }).catch(error => {
                    console.log(error)
                })

            })
        },

        patchTranslationString(string) {

            clearTimeout(this.timeout)

            this.timeout = setTimeout(() => {

                this.http.patch(`/babel/translation/strings/${string.id}.json`, {
                    translation_string: {
                        context: string.context,
                        status: string.status,
                        label: string.label,
                        en: string.en,
                        es: string.es,
                        de: string.de
                    }
                }).then(result => {
                    this.alert("Translation updated successfully", "success" )
                    console.log(result)
                }).catch(error => {
                    console.log(error)
                })

            }, 1500)

        },

        postTranslationString(object) {
            this.http.post('/babel/translation/strings.json', {
                translation_string: {
                    context: '',
                    label: this.label,
                    en: '',
                    es: '',
                    de: '',
                    cloud_babel_translation_objects_id: object.id
                }
            }).then(result => {
                this.alert("Label successfully added", "success")
                this.label = ''
            }).catch(error => {
                console.log(error)
            })
        }

    },
    watch: {
        'selection.module': function() {
            this.getModuleObjects()
        },
        'selection.object': function() {
            this.getModuleObjectTypes()
            if (this.selection.object.name == 'shared') {
                this.sharedTranslationString = true
                this.getModuleObjectTypeActionSectionStrings()
            } else {
                this.sharedTranslationString = false
            }
        },
        'selection.obtype': function() {
            this.getModuleObjectTypeActions()
        },
        'moduleObjectTypeActions': function() {
            this.getModuleObjectTypeStrings()
        },


        'selection.action': function() {
            this.getModuleObjectTypeActionSections()
        },
        'selection.section': function() {
            this.getModuleObjectTypeActionSectionStrings()
        }
    }
}
</script>
<template>
    <section class="section">
        <div class="card">
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
                            v-model="selection.object">
                            <option v-for="object in moduleObjects" :key="object.id" :value="object">{{ object.name }}</option>
                        </b-select>
                    </div>

                    <template v-if="!sharedTranslationString">

                        <div class="control">
                            <b-select
                                placeholder="Select type"
                                icon="globe"
                                icon-pack="fas"
                                v-model="selection.obtype">
                                <option v-for="type in moduleObjectTypes" :key="type.id" :value="type">{{ type.name }}</option>
                            </b-select>
                        </div>

                        <div class="control" v-if="false">
                            <b-select
                                placeholder="Select action"
                                icon="globe"
                                icon-pack="fas"
                                v-model="selection.action">
                                <option v-for="action in moduleObjectTypeActions" :key="action.id" :value="action">{{ action.name }}</option>
                            </b-select>
                        </div>

                        <div class="control" v-if="false">
                            <b-select
                                placeholder="Select section"
                                icon="globe"
                                icon-pack="fas"
                                v-model="selection.section">
                                <option v-for="section in moduleObjectTypeActionSections" :key="section.id" :value="section">{{ section.name }}</option>
                            </b-select>
                        </div>

                    </template>
                    
                </div>
            </div>
        </div>

        <br />

        <div class="card">
            <b-tabs>
                <b-tab-item v-for="action in moduleObjectTypeActions" :key="action.id">
                    <template slot="header">
                        <i class="far fa-comment-dots"></i>
                        <span>
                            {{ action.name }}
                            <b-tag rounded>{{ action.strings.length }}</b-tag>
                        </span>
                    </template>
                    <!-- <form @submit.prevent="postTranslationString(action)">
                        <div class="control has-icons-left has-icons-right">
                            <input class="input is-hovered" type="text" v-model="label" placeholder="Add label to translation workflow">
                            <span class="icon is-small is-left">
                                <i class="fas fa-language"></i>
                            </span>
                        </div>
                    </form> -->
                    <b-table 
                        detailed 
                        detail-key="id" 
                        :show-detail-icon="true"
                        :data="action.strings">
                        <template v-slot="props">
                            <b-table-column field="label" label="Label">
                                {{ props.row.label }}
                            </b-table-column>
                            <b-table-column field="en" label="en">
                                <input type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.en" />
                            </b-table-column>
                            <b-table-column field="es" label="es">
                                <input type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.es" />
                            </b-table-column>
                            <b-table-column field="de" label="de">
                                <input type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.de" />
                            </b-table-column>
                            <b-table-column label="status">
                                <div class="select">
                                    <select v-on:change="patchTranslationString(props.row)" v-model="props.row.status">
                                        <option value="0">pending</option>
                                        <option value="1">completed</option>
                                    </select>
                                </div>
                            </b-table-column>
                        </template>
                        <template slot="detail" slot-scope="props">
                            <input type="text" class="is-fullwidth" v-on:input="patchTranslationString(props.row)" v-model="props.row.context" />
                        </template>
                    </b-table>
                </b-tab-item>
                <b-tab-item></b-tab-item>
            </b-tabs>
        </div>
    </section>
</template>
