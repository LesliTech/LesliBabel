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

export default {
    props: {
        bucket: {

        },
        module: {

        }
    },
    data() {
        return {
            label: "",
            strings: [],
            timeout: null,
            loading: false
        }
    },
    mounted() {
        this.getBucketStrings()
    },
    methods: {

        getBucketStrings() {

            this.strings = []
            this.loading = true

            // get strings for module (default)
            let url = `/babel/translation/modules/${this.module.id}/strings.json`

            // if user selects bucket
            if (this.bucket.id) {
                url = `/babel/translation/modules/${this.module.id}/buckets/${this.bucket.id}/strings.json`
            }

            this.http.get(url).then(result => {
                if (!result.successful) return 
                this.strings = result.data ? result.data : []
                this.loading = false
            }).catch(error => {
                console.log(error)
                this.loading = false
            })
           
        },

        postTranslationString() {
            this.http.post('/babel/translation/strings.json', {
                translation_string: {
                    context: '',
                    label: this.label,
                    en: '',
                    es: '',
                    de: '',
                    cloud_babel_translation_buckets_id: this.bucket.id
                }
            }).then(result => {
                if (!result) this.alert("Error adding label", "danger")
                this.notification.alert("Label successfully added", "success")
                this.getBucketStrings()
                this.label = ''
            }).catch(error => {
                console.log(error)
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
                    this.notification.alert("Translation updated successfully", "success" )
                }).catch(error => {
                    console.log(error)
                })
            }, 1500)
        },

        putTranslationStringHelpRequest(string) {
            this.http.put(`/babel/translation/strings/${string.id}/help_request.json`, {
            }).then(result => {
                this.notification.alert("Help requested successfully", "success" )
            }).catch(error => {
                console.log(error)
            })
        },

        sendToClipboard(string) {
            const el = document.createElement('textarea');
            el.value = string
            el.setAttribute('readonly', '');
            el.style.position = 'absolute';
            el.style.left = '-9999px';
            document.body.appendChild(el);
            el.select();
            document.execCommand('copy');
            document.body.removeChild(el);
            this.notification.alert("Copied to clipboard")
        },
        getRowClass(row) {

            var row_class = []

            if (row.context && row.context != "") {
                row_class.push("bbl-context")
            }

            if (row.help_needed) {
                row_class.push("bbl-help")
            }

            return row_class.join(" ")
        }

    },
    watch: {
        'bucket': function() {
            this.getBucketStrings()
        },
        'module': function() {
            this.getBucketStrings()
        }
    }
}
</script>
<template>
    <section>
        <component-data-loading class="section" v-if="loading"></component-data-loading>
        <component-data-empty v-if="!loading && strings.length == 0"></component-data-empty>
        <div class="card" v-if="strings.length > 0">
            <div class="card-header">
                <h4 class="card-header-title">
                    Labels
                </h4>
                <div class="card-header-icon" v-if="this.bucket.id">
                    <form @submit.prevent="postTranslationString()">
                        <div class="field has-addons">
                            <p class="control">
                                <a class="button is-static">
                                    Add new string:
                                </a>
                            </p>
                            <div class="control has-icons-left has-icons-right">
                                <input class="input is-hovered" type="text" v-model="label" placeholder="Add label to translation workflow">
                                <span class="icon is-small is-left">
                                    <i class="fas fa-language"></i>
                                </span>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            <div class="table-container">
                <b-table 
                    detailed 
                    detail-key="id" 
                    :show-detail-icon="true"
                    :data="strings"
                    :row-class="getRowClass">
                    <template v-slot="props" class="ldonis">
                        <b-table-column class="copy">
                            <button class="button is-text" @click="sendToClipboard(props.row.path)" :title="props.row.path">
                                <i class="far fa-copy"></i>
                            </button>
                        </b-table-column>
                        <b-table-column field="label" label="Label">
                            <button class="button is-text" @click="sendToClipboard(props.row.label)" :title="props.row.path">
                                {{ props.row.label }}
                            </button>
                        </b-table-column>
                        <b-table-column field="en" label="en" sortable>
                            <input type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.en" />
                        </b-table-column>
                        <b-table-column field="es" label="es" sortable>
                            <input type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.es" />
                        </b-table-column>
                        <b-table-column field="de" label="de" sortable>
                            <input type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.de" />
                        </b-table-column>
                        <!-- 
                        <b-table-column label="status">
                            <div class="select">
                                <select v-on:change="patchTranslationString(props.row)" v-model="props.row.status">
                                    <option value="0">pending</option>
                                    <option value="1">completed</option>
                                </select>
                            </div>
                        </b-table-column>
                        -->
                    </template>
                    <template slot="detail" slot-scope="props">
                        <div class="columns">
                            <div class="column is-11">
                                <div class="field">
                                    <label class="label">Context</label>
                                    <div class="control">
                                        <input class="input" type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.context">
                                    </div>
                                </div>
                            </div>
                            <div class="column is-1">
                                <div class="field">
                                    <label class="label">&nbsp;</label>
                                    <div class="control">
                                        <b-tooltip label="Request help">
                                            <button class="button" @click="putTranslationStringHelpRequest(props.row)">?</button>
                                        </b-tooltip>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                </b-table>
            </div>
        </div>
    </section>
</template>
