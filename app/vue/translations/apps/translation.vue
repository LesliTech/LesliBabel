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
            modules: [
                { 'id': 'core', 'name': 'Core'},
                { 'id': 1, 'name': 'Lesli'},
                { 'id': 2, 'name': 'Help'},
                { 'id': 3, 'name': 'Lock'},
                { 'id': 4, 'name': 'Babel'},
                { 'id': 5, 'name': 'Driver'},
                { 'id': 6, 'name': 'Bell'},
                { 'id': 7, 'name': 'Team'}
            ],
            columns: [{
                field: 'label',
                label: 'Label'
            }],
            translations: [],
            translationObjects: [],
            translationObjectGroups: [],
            translationObjectGroupLabels: [],
            label: '',
            selection: {
                translation: null,
                object: null,
                group: null,
                module: null
            },
            timeout: null
        }
    },
    mounted() {
        this.selection = { "translation": { "id": 65, "module_name": "core", "class_name": "websites", "created_at": "2019-12-18T14:23:16.046Z", "updated_at": "2019-12-18T14:23:16.046Z" }, "object": { "id": 123, "object_type": "views", "created_at": "2019-12-18T14:23:16.051Z", "updated_at": "2019-12-18T14:23:16.051Z", "cloud_babel_translations_id": 65 }, "group": { "id": 1001, "method": "index", "section": "messages", "created_at": "2019-12-18T14:23:16.055Z", "updated_at": "2019-12-18T14:23:16.055Z", "cloud_babel_translation_objects_id": 123 }, "module": { "id": "core", "name": "Core" } } 
    },
    methods: {

        getTranslations() {
            this.http.get(`/babel/translations/${this.selection.module.id}.json`).then(result => {
                if (!result.successful) return 
                this.translations = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getTranslationObjects() {
            this.http.get(`/babel/translations/${this.selection.translation.id}/translation_objects.json`).then(result => {
                if (!result.successful) return 
                this.translationObjects = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getTranslationObjectGroups() {
            this.http.get(`/babel/translations/${this.selection.translation.id}/translation_objects/${this.selection.object.id}/translation_object_groups.json`).then(result => {
                if (!result.successful) return 
                this.translationObjectGroups = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getTranslationObjectGroupLabels() {
            this.http.get(`/babel/translations/${this.selection.translation.id}/translation_objects/${this.selection.object.id}/translation_object_groups/${this.selection.group.id}/translation_object_group_labels.json`).then(result => {
                if (!result.successful) return 
                this.translationObjectGroupLabels = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        buildLabelPath(label) {
            return [
                this.selection.translation.module_name,
                this.selection.translation.class_name,
                this.selection.object.object_type,
                this.selection.group.method,
                this.selection.group.section,
                label
            ].join('.')
        },

        postTranslationObjectGroupLabels(e) {

            if (e) { e.preventDefault(); }
            
            this.http.post('/babel/translation_object_group_labels', {
                context: '',
                label: this.label,
                en: '',
                es: '',
                de: '',
                cloud_babel_translation_object_groups_id: this.selection.group.id
            }).then(result => {
                this.alert("Label successfully added", "success")
                this.getTranslationObjectGroupLabels()
                this.label = ''
            }).catch(error => {
                console.log(error)
            })

        },

        patchTranslationObjectGroupLabels(label) {
            clearTimeout(this.timeout)
            this.timeout = setTimeout(() => {
                this.http.put(`/babel/translation_object_group_labels/${label.id}`, {
                    context: label.context,
                    label: label.label,
                    en: label.en,
                    es: label.es,
                    de: label.de
                }).then(result => {
                    console.log(result)
                    this.alert("Translation updated successfully", 'success' )
                }).catch(error => {
                    console.log(error)
                })
            }, 1500)
        },

        test(d) {
            console.log(d)
        }

    },
    watch: {
        'selection.module': function() {
            this.getTranslations()
        },
        'selection.translation': function() {
            this.getTranslationObjects()
        },
        'selection.object': function() {
            this.getTranslationObjectGroups()
        },
        'selection.group': function() {
            this.getTranslationObjectGroupLabels()
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
                            placeholder="Select class"
                            icon="globe"
                            icon-pack="fas"
                            v-model="selection.translation">
                            <option v-for="translation in translations" :key="translation.id" :value="translation">{{ translation.class_name }}</option>
                        </b-select>
                    </div>

                    <div class="control">
                        <b-select
                            placeholder="Select object"
                            icon="globe"
                            icon-pack="fas"
                            v-model="selection.object">
                            <option v-for="object in translationObjects" :key="object.id" :value="object">{{ object.object_type }}</option>
                        </b-select>
                    </div>

                    <div class="control">
                        <b-select
                            placeholder="Select group"
                            icon="globe"
                            icon-pack="fas"
                            v-model="selection.group">
                            <option v-for="group in translationObjectGroups" :key="group.id" :value="group">{{ group.method }} - {{ group.section }}</option>
                        </b-select>
                    </div>
                </div>
            </div>
        </div>
        <br />
        <div class="card">
            <div class="card-header">
                <h4 class="card-header-title">
                    All the labels
                </h4>
                <div class="card-header-icon">
                    <form @submit.prevent="postTranslationObjectGroupLabels()">
                        <div class="control has-icons-left has-icons-right">
                            <input class="input is-hovered" type="text" v-model="label" placeholder="Add label to translation workflow">
                            <span class="icon is-small is-left">
                                <i class="fas fa-language"></i>
                            </span>
                        </div>
                    </form>
                </div>
            </div>
            <div class="card-content">
                <b-table 
                    :data="translationObjectGroupLabels">
                    <template v-slot="props">
                        <b-table-column field="label" label="Label">
                            {{ props.row.label }}
                        </b-table-column>
                        <b-table-column field="context" label="Context">
                            {{ props.row.context }}
                        </b-table-column>
                        <b-table-column field="en" label="en"  >
                            <input type="text" v-on:input="patchTranslationObjectGroupLabels(props.row)" v-model="props.row.en" />
                        </b-table-column>
                        <b-table-column field="es" label="es"  >
                            <input type="text" v-on:input="patchTranslationObjectGroupLabels(props.row)" v-model="props.row.es" />
                        </b-table-column>
                        <b-table-column field="de" label="de"  >
                            <input type="text" v-on:input="patchTranslationObjectGroupLabels(props.row)" v-model="props.row.de" />
                        </b-table-column>
                    </template>
                </b-table>
            </div>
        </div>
    </section>
</template>
