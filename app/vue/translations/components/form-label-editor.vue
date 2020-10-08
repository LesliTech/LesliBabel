<script>
export default {
    props: {
        strings: {
            required: true
        },
        options: {
            required: true
        },
        pagination: {
            required: true
        },
        quickviewToggleFunction: {
            required: true
        },
        selectedStringId: {
            required: true
        }
    },
    data() {
        return {
            locales_available: {}
        }
    },
    mounted() {
        document.addEventListener("keyup", this.nextItem);
    },
    methods: {

        nextItem (e) {

            e = e || window.event;

            if (!e.target.dataset.column_id) {
                return
            }

            let column_id = e.target.dataset.column_id
            let row_id = e.target.dataset.row_id

            if (e.keyCode == '38') {
                // up arrow
                column_id--
            }
            else if (e.keyCode == '40') {
                // down arrow
                column_id++
            }
            else if (e.keyCode == '37') {
                // left arrow
                row_id--
            }
            else if (e.keyCode == '39') {
                // right arrow
                row_id++
            }

            let ref_input = `input-${column_id}-${row_id}`

            if (!this.$refs[ref_input]) {
                return
            }

            this.$refs[ref_input][0].focus()

        },

        patchTranslationString(string) {
            clearTimeout(this.timeout)
            this.timeout = setTimeout(() => {
                this.http.patch(`/babel/strings/${string.id}.json`, {
                    string: string
                }).then(result => {
                    this.alert("Translation updated successfully", "success" )
                }).catch(error => {
                    console.log(error)
                })
            }, 1500)
        },

        deleteTranslationString(string) {
            window.scrollTo(0,0)
            this.$buefy.dialog.confirm({
                title: 'Delete String',
                message: 'Are you sure you want to continue? This action is irreversible. If at some point you want the string back, you will have to add it manually.',
                confirmText: 'Yes, Delete it',
                cancelText: 'Cancel',
                type: 'is-danger',
                hasIcon: true,
                onConfirm: ()=>{
                    this.http.delete(`/babel/strings/${string.id}.json`, {
                    }).then(result => {
                        if (result.successful) {
                            this.strings.records = this.strings.records.filter((record)=>{
                                return record.id != string.id
                            })
                            this.alert("Translation deleted successfully", "success" )
                        }else{
                            this.alert(result.error.message,'danger')
                        }
                    }).catch(error => {
                        console.log(error)
                    })
                }
            })
        },

        putTranslationStringNeedHelp(string) {
            this.http.put(`/babel/strings/${string.id}/resources/need-help.json`, {
            }).then(result => {
                string.need_help = ! string.need_help

                if(string.need_help){
                    this.alert("Help requested successfully", "success" )
                }else{
                    this.alert("Help request cleared", "success" )
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putTranslationStringNeedTranslation(string) {
            this.http.put(`/babel/strings/${string.id}/resources/need-translation.json`, {
            }).then(result => {
                string.need_translation = ! string.need_translation

                if(string.need_translation){
                    this.alert("Translation requested successfully", "success" )
                }else{
                    this.alert("Translation request cleared", "success" )
                }
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
        },

        toggleQuickview(string){
            this.$emit('update:selected-string-id', string.id)
            this.quickviewToggleFunction()
        },

        getRowClass(row) {

            var row_class = []

            if (row.context && row.context != "") {
                row_class.push("has-context")
            }

            if (row.need_help) {
                // same color as the button
                row_class.push("has-background-warning")
            }

            if (row.need_translation) {
                // same color as the button
                row_class.push("has-background-info")
            }

            return row_class.join(" ")

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
                <b-table-column field="label" label="Label">
                    <button 
                        class="button is-text is-paddingless" 
                        @click="sendToClipboard(props.row.label)">
                        {{ props.row.label }}
                    </button>
                </b-table-column>
                <b-table-column 
                    v-for="(locale_name, locale_code, index) in options.locales_available" 
                    :key="locale_code" 
                    :field="locale_code" 
                    :label="locale_name" 
                    sortable>
                    <input 
                        type="text" 
                        class="input" 
                        :tabindex="props.row.id + (strings.records.length * index)"
                        :data-column_id="props.row.id"
                        :data-row_id="index"
                        :data-column_total="strings.records.length"
                        :ref="`input-${props.row.id}-${index}`"
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
                                <small @click="sendToClipboard(props.row.path)"><i>path:</i>{{ props.row.path }}</small>
                            </div>
                        </div>
                    </div>
                    <div class="column is-2 has-text-center">
                        <div class="field">
                            <label class="label">Options</label>
                            <div class="control has-text-center">
                                <div class="buttons">
                                    <button 
                                        :class="['button', 'is-warning', {'is-outlined': !props.row.need_help}]" 
                                        @click="putTranslationStringNeedHelp(props.row)">
                                        <b-tooltip label="Need help" type="is-warning">
                                            <span class="icon">
                                                <i class="fas fa-question-circle"></i>
                                            </span>
                                        </b-tooltip>
                                    </button>
                                    <button 
                                        :class="['button', 'is-info', {'is-outlined': !props.row.need_translation}]" 
                                        @click="putTranslationStringNeedTranslation(props.row)">
                                        <b-tooltip label="Need translation">
                                            <span class="icon">
                                                <i class="fas fa-language"></i>
                                            </span>
                                        </b-tooltip>
                                    </button>
                                    <button 
                                        :class="['button', {'is-outlined': !props.row.need_help}]" 
                                        @click="toggleQuickview(props.row)"
                                    >
                                        <b-tooltip label="Open Discussions/Activities" type="is-white">
                                            <span class="icon">
                                                <i class="fas fa-info-circle"></i>
                                            </span>
                                        </b-tooltip>
                                    </button>
                                    <button 
                                        class="button is-danger is-pulled-right" 
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
        <hr>
        <section class="container pb-5">
            <b-pagination
                :simple="false"
                :total="pagination.total_count"
                :current.sync="pagination.current_page"
                :range-before="pagination.range_before"
                :range-after="pagination.range_after"
                :per-page="pagination.per_page"
                order="is-centered"
                icon-prev="chevron-left"
                icon-next="chevron-right"
                aria-next-label="Next page"
                aria-previous-label="Previous page"
                aria-page-label="Page"
                aria-current-label="Current page"
            >
            </b-pagination>
        </section>
    </div>
</template>
