<script>
export default {
    props: {
        strings: {},
        options: {}
    },
    data() {
        return {
            locales_available: {}
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
                    translation_string: string
                }).then(result => {
                    this.alert("Translation updated successfully", "success" )
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
                this.alert("Translation deleted successfully", "success" )
            }).catch(error => {
                console.log(error)
            })
        },

        putTranslationStringNeedHelp(string) {
            this.http.put(`/babel/translation/strings/${string.id}/resources/need-help.json`, {
            }).then(result => {
                this.alert("Help requested successfully", "success" )
            }).catch(error => {
                console.log(error)
            })
        },

        putTranslationStringNeedTranslation(string) {
            this.http.put(`/babel/translation/strings/${string.id}/resources/need-translation.json`, {
            }).then(result => {
                this.alert("Translation requested successfully", "success" )
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
            this.alert("Copied to clipboard")
        }

    }
}
</script>
<template>
    <div class="card table-container">
        <b-table 
            detailed 
            detail-key="id" 
            :data="strings.records"
            :show-detail-icon="true"
            :row-class="getRowClass">
            <template v-slot="props">
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
                <b-table-column 
                    v-for="(locale_name, locale_code) in options.locales_available" 
                    :key="locale_code" 
                    :field="locale_code" 
                    :label="locale_name" 
                    sortable>
                    <input 
                        type="text" 
                        class="input" 
                        v-model="props.row[locale_code]"
                        v-on:input="patchTranslationString(props.row)"
                    />
                </b-table-column>
            </template>
            <template slot="detail" slot-scope="props">
                <div class="columns">
                    <div class="column is-10">
                        <div class="field">
                            <label class="label">Context</label>
                            <div class="control">
                                <input 
                                    type="text" 
                                    class="input" 
                                    v-model="props.row.context"
                                    v-on:input="patchTranslationString(props.row)">
                            </div>
                        </div>
                    </div>
                    <div class="column is-12 has-text-center">
                        <div class="field">
                            <label class="label">Options</label>
                            <div class="control has-text-center">
                                <div class="buttons">
                                    <button 
                                        class="button is-primary" 
                                        @click="putTranslationStringNeedHelp(props.row)">
                                        <b-tooltip label="Need help">
                                        ?
                                        </b-tooltip>
                                    </button>
                                    <button 
                                        class="button is-primary" 
                                        @click="putTranslationStringNeedTranslation(props.row)">
                                        <b-tooltip label="Need translation">
                                            <span class="icon">
                                                <i class="fas fa-language"></i>
                                            </span>
                                        </b-tooltip>
                                    </button>
                                    <button 
                                        class="button is-danger" 
                                        @click="deleteTranslationString(props.row)">
                                        <b-tooltip label="Delete label" type="is-danger">
                                            <span class="icon">
                                                <i class="far fa-trash-alt"></i>
                                            </span>
                                        </b-tooltip>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </template>
        </b-table>
    </div>
</template>
