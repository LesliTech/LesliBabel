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
        }
    },
    mounted() {
        this.getBucketStrings()
    },
    methods: {

        getBucketStrings() {
            this.http.get(`/babel/translation/modules/${this.module.id}/buckets/${this.bucket.id}/strings.json`).then(result => {
                if (!result.successful) return 
                this.strings = result.data ? result.data : []
            }).catch(error => {
                console.log(error)
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
                this.alert("Label successfully added", "success")
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
                    this.alert("Translation updated successfully", "success" )
                    console.log(result)
                }).catch(error => {
                    console.log(error)
                })
            }, 1500)
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
            this.alert("Copied to clipboard")
        }

    },
    watch: {
        'bucket': function() {
            this.getBucketStrings()
        }
    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                Labels
            </h4>
            <div class="card-header-icon">
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
        <b-table 
            detailed 
            detail-key="id" 
            :show-detail-icon="true"
            :data="strings">
            <template v-slot="props">
                <b-table-column field="label" label="Label">
                    <button class="button is-text" @click="sendToClipboard(props.row.path)" :title="props.row.path">
                        {{ props.row.label }}
                    </button>
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
    </div>
</template>
