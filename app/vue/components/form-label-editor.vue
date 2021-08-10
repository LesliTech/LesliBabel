<script>
export default {
    props: {
        strings: {
            required: true
        }
    },
    data() {
        return {
            options: {},
            locales_available: {}
        }
    },
    mounted() {
        document.addEventListener("keydown", this.nextItem);
        this.getOptions()
    },
    methods: {

        nextItem (e) {

            e = e || window.event;

            if (!e.target.dataset.column_id) {
                return
            }

            let text_input = e.target

            let column_id = e.target.dataset.column_id
            let row_id = text_input.dataset.row_id

            let cursor_position = this.cursorPosition(text_input)

            if(cursor_position.at_start){
                if (e.keyCode == '37') {
                    // left arrow
                    e.preventDefault()
                    row_id--
                }
            }

            if(cursor_position.at_end){
                if (e.keyCode == '39') {
                    // right arrow
                    row_id++
                }
            }

            if (e.keyCode == '38') {
                e.preventDefault()
                // up arrow
                column_id--
            } else if (e.keyCode == '40') {
                e.preventDefault()
                // down arrow
                column_id++
            }

            let ref_input = `input-${column_id}-${row_id}`

            if(this.$refs[ref_input] && this.$refs[ref_input][0]){
                this.$refs[ref_input][0].focus()
            }


        },

        //This method verifies if the cursor is at the start or end o a "text" type input
        cursorPosition(text_input){
            let input_value = text_input.value

            let at_start = false
            let at_end = false
            
            if (typeof text_input.selectionStart == "number") {
                // Non-IE browsers
                at_start = (text_input.selectionStart == 0);
                at_end = (text_input.selectionEnd == input_value.length);
            } else if (document.selection && document.selection.createRange) {
                // IE <= 8 branch
                text_input.focus();
                let selRange = document.selection.createRange();
                let inputRange = text_input.createTextRange();
                let inputSelRange = inputRange.duplicate();
                inputSelRange.moveToBookmark(selRange.getBookmark());
                at_start = inputSelRange.compareEndPoints("StartToStart", inputRange) == 0;
                at_end = inputSelRange.compareEndPoints("EndToEnd", inputRange) == 0;
            }

            return {
                at_start: at_start,
                at_end: at_end
            }
        },

        getOptions() {

            this.options = {}
            this.http.get("/babel/translations/options.json").then(result => {
                this.options = result.data
            }).catch(error => {
                console.log(error)
            })

        },

        patchTranslationString(string) {
            clearTimeout(this.timeout)
            this.timeout = setTimeout(() => {
                this.http.patch(`/babel/strings/${string.id}.json`, {
                    string: string
                }).then(result => {
                    this.msg.success("Translation updated successfully")
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
                            this.msg.success("Translation deleted successfully")
                        }else{
                            this.msg.error(result.error.message)
                        }
                    }).catch(error => {
                        console.log(error)
                    })
                }
            })
        },

        putTranslationStringNeedHelp(string) {
            this.http.put(`/babel/strings/${string.id}/resources/need_help.json`, {
            }).then(result => {
                string.need_help = ! string.need_help

                if(string.need_help){
                    this.msg.success("Help requested successfully")
                }else{
                    this.msg.success("Help request cleared")
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putTranslationStringNeedTranslation(string) {
            this.http.put(`/babel/strings/${string.id}/resources/need_translation.json`, {
            }).then(result => {
                string.need_translation = ! string.need_translation

                if(string.need_translation){
                    this.msg.success("Translation requested successfully")
                }else{
                    this.msg.success("Translation request cleared")
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
            this.msg.info("Copied to clipboard")
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
    <div class="card is-shadowless table-container">
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
                        @click="sendToClipboard(props.row.label)"
                        v-on:dblclick="sendToClipboard(props.row.path)">
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
                        :tabindex="strings.records.length + props.index + (strings.records.length * index)"
                        :data-column_id="props.index"
                        :data-row_id="index"
                        :data-column_total="strings.records.length"
                        :ref="`input-${props.index}-${index}`"
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
                                        :class="['button', 'is-warning']" 
                                        @click="putTranslationStringNeedHelp(props.row)">
                                        <b-tooltip label="Need help" type="is-warning">
                                            <span class="icon">
                                                <i class="fas fa-question-circle"></i>
                                            </span>
                                        </b-tooltip>
                                    </button>
                                    <button 
                                        :class="['button', 'is-info']" 
                                        @click="putTranslationStringNeedTranslation(props.row)">
                                        <b-tooltip label="Need translation">
                                            <span class="icon">
                                                <i class="fas fa-language"></i>
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
    </div>
</template>
