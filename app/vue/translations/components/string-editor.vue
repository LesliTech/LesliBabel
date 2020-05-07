<script>
export default {
    props: {
        showPath: {
            default: false
        },
        strings: {
        }
    },
    methods: {

        getRowClass(row) {

            var row_class = []

            if (row.context && row.context != "") {
                row_class.push("bbl-context")
            }

            if (row.help_needed) {
                row_class.push("bbl-help")
            }

            return row_class.join(" ")
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

        deleteTranslationString(string) {
            this.http.delete(`/babel/translation/strings/${string.id}.json`, {
            }).then(result => {
                setTimeout(() => {
                    this.getBucketStrings()
                }, 1000)
                this.notification.alert("Translation deleted successfully", "success" )
            }).catch(error => {
                console.log(error)
            })
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
        }

    }
}
</script>
<template>
    <div class="table-container" v-if="strings.length > 0">
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
                    <small v-if="showPath">
                        {{ props.row.path }}
                    </small>
                </b-table-column>
                <b-table-column field="en" label="en" sortable>
                    <input type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.en" />
                </b-table-column>
                <!-- 
                <b-table-column field="es" label="es" sortable>
                    <input type="text" v-on:input="patchTranslationString(props.row)" v-model="props.row.es" />
                </b-table-column> 
                -->
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
                    <div class="column is-1 has-text-center">
                        <div class="field">
                            <label class="label">&nbsp;</label>
                            <div class="control">
                                <b-tooltip label="Request help">
                                    <button class="button" @click="putTranslationStringHelpRequest(props.row)">?</button>
                                </b-tooltip>
                                <b-tooltip label="Delete label">
                                    <button class="button is-danger is-light" @click="deleteTranslationString(props.row)">
                                        <span class="icon">
                                            <i class="far fa-trash-alt"></i>
                                        </span>
                                    </button>
                                </b-tooltip>
                            </div>
                        </div>
                    </div>
                </div>
            </template>
        </b-table>
    </div>
</template>
