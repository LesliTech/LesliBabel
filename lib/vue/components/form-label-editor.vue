<script setup>
/*
Copyright (c) 2022, all rights reserved.

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


// · import vue tools
import { ref, reactive, onMounted, watch, computed, onUnmounted } from "vue"
import { useRouter, useRoute } from 'vue-router'


// · import lesli stores
const route = useRoute()
import { useStrings } from "LesliBabel/vue/stores/strings"
import { useTranslations } from "LesliBabel/vue/stores/translations"
import { useServiceTranslator } from "Lesli/vue/shared/services/translator"


// · implement stores
const storeStrings = useStrings()
const storeTranslations = useTranslations()
const storeServiceTranslator = useServiceTranslator()


// · 
const props = defineProps({
    module: {
        type: [Number, String],
        require: false
    }
})


// · columns of the editor table
const columns = ref([])


// · selected language to work with
const language = ref(null)


// · 
onMounted(() => {

    // english by default if custom language not sent through url
    language.value = route.query?.locale ?? 'en'

    // get options for translations
    storeTranslations.fetchOptions()

})


// · get translations checking configuration provided through the store or query
function fetchTranslations() {

    // always reset the config
    storeStrings.search = ""
    storeStrings.module = 0
    storeStrings.ids = null

    // work with relevant translations
    if (props.module == "relevants") {
        return storeStrings.fetchRelevant()
    }

    // check if labels ids are provided
    if (route.query?.ids) {
        storeStrings.ids = route.query?.ids
    }

    // check if search params is provided through query
    if (route.query?.search) {
        storeStrings.search = route.query?.search
    }

    // work with an specific module if provided
    if (props.module) {
        storeStrings.module = props.module
    }

    return storeStrings.fetchStrings()

}


// · load all the columns available for the editor
function resetColumns() {

    // reset columns
    columns.value = []

    // load defaults columns for the editor table
    columns.value.push({
        label: 'Label to translate',
        field: 'label'
    })

    // dynamic add the column related to the selected working language
    columns.value.push({
        label: storeTranslations?.options?.locales_available[language.value],
        field: language.value,
        width: '100%'
    })
}


// · build the title for the table custom headers
// · this is necessary to show the custom header cell for every language 
// · (we show only one language at the time)
function languageHead(language) {
    return 'head('+language+')'
}


// suggest translation from english to desire language
// to make this work we need to have the label already translated to english 
function suggestTranslation(label, locale) {

    // we use the translator service (integrated with google translate)
    // we always send the text in english due the label key is compound with the 
    // collection and bucket names
    storeServiceTranslator.getTranslation(label["en"], "en", locale).then(result => {

        // update the translation
        label[locale] = result.translatedText

        // custom property added just here to let the editor know that an automatic
        // translation was added to the label
        label[`translated_${locale}`] = true
    })
}


// remove a translation for a specific locale
// mostly used with suggested translations
function clearStringTranslation(record, locale) {
    record[locale] = ''
    record[`translated_${locale}`] = false
}


// build a string to use as direct link to the selected label
function getLabelLink(id) {
    return `${window.location.host}/babel/translations?ids=${id}`
}


// switch a label as help needed
function askForHelp(record) {
    record.need_help = !record.need_help
    storeStrings.putString(record)
}


// switch a label as help needed
function askForTranslation(record) {
    record.need_translation = !record.need_translation
    storeStrings.putString(record)
}


// · get strings for the module selected, reset if module changed
watch(() => props.module, () => {
    storeStrings.search = ""
    storeStrings.module = props.module
    fetchTranslations()
})


watch(() => route.query.search, string => {
    storeStrings.search = string
    fetchTranslations()
})


// · changing the working language, keep config if language changed
watch(() => language.value, (language) => {
    storeStrings.language = language
    fetchTranslations()
    resetColumns()
})


// · watch for the locales available to dynamically show language columns in the editor
watch(() => storeTranslations.options.locales_available, () => {
    resetColumns()
})


// · go to the first input once translations loaded
watch(() => storeStrings.strings.records, () => {
    setTimeout(() => { nextTranslation() }, 1000) 
})


// · 
function copyToClipboard(button, text) {
    const el = document.createElement('textarea');
    el.value = text; // text to copy
    el.setAttribute('readonly', '');
    el.style.position = 'absolute';
    el.style.left = '-9999px';
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
    button.target.classList.add('copied')
    setTimeout(() => button.target.classList.remove('copied'), 1000)
}


// · Navigate to the next translation using arrow keys
function nextTranslation () {
    return
    var table = document.getElementById("babel-translations")
    var inputs = table.getElementsByTagName("input")

    for(var i = 0 ; i < inputs.length;i++) {

        // add a listener for keydown
        inputs[i].addEventListener('keydown', function(e){

            // execute only for down/up/enter keys
            if (e.keyCode == 38 || e.keyCode == 40 || e.keyCode == 13) {
            
                // remove default behavior for arrow keys
                e.preventDefault()

                // get the index of the current index
                var currentIndex = findElement(e.target)

                // work only with valid index between 0 ~ n
                if (currentIndex < 0 || currentIndex > inputs.length) {
                    return 
                }

                // downkey
                if (e.keyCode == 38) {
                    if (inputs[currentIndex-1]) {
                        inputs[currentIndex-1].focus();
                    }
                }
                
                // upkey
                if (e.keyCode == 40 || e.keyCode == 13) {
                    if (inputs[currentIndex+1]) {
                        inputs[currentIndex+1].focus();
                    }
                }

            }

        });
    }

    // get the current selected input
    function findElement(element) {
        var index = -1;
        for(var i = 0; i < inputs.length; i++) {
            if(inputs[i] == element) {
                return i;
            }
        }
        return index;
    }

}

</script>
<template>
    <lesli-table
        id="babel-translations"
        :loading="storeStrings.strings.loading"
        :records="storeStrings.strings.records"
        :columns="columns"
        @paginate="storeStrings.fetchStrings()"
        @details="nextTranslation()">

        <!-- Table custom header, renders a language selector -->
        <template :[languageHead(language)]="{ column }">
            <lesli-select
                icon="public"
                v-model="language"
                :options="storeTranslations.locales">
            </lesli-select>
        </template>

        <!--  Print the label string with a button to easely copy to clipboard -->
        <template #label="{ record }">
            <button 
                class="button is-white p-0" 
                @click.stop="copyToClipboard($event, record.label)"
                @contextmenu.capture.prevent="copyToClipboard($event, record.path)">
                <span class="icon has-text-grey">
                    <span class="material-icons">
                        content_copy
                    </span>
                </span>
                <span>
                    {{ record.label }}
                </span>
            </button>
        </template>

        <!--  Print a input to edit the translation for the current locale -->
        <template :[language]="{ value, record }">
            <div class="is-flex is-align-items-center">
                <input 
                    type="text"
                    class="input"
                    placeholder="Add translations..."
                    @input="storeStrings.updateString(record, language)"
                    v-model="record[language]"
                />
                <span class="icon mx-1" v-if="record.need_help">
                    <span class="material-icons has-text-info">
                        help_outline
                    </span>
                </span>
                <span class="icon mx-1" v-if="record.need_translation">
                    <span class="material-icons has-text-warning-dark">
                        translate
                    </span>
                </span>
            </div>
        </template>

        <template #detail="{ record }">
            <tr v-for="(locale_name, locale_code) in storeTranslations.options.locales_available">
                <td></td>
                <td class="has-text-right">{{ locale_name }}</td>
                <td class="is-flex is-align-items-center">
                    <input 
                        type="text"
                        class="input"
                        placeholder="Add translations..."
                        v-model="record[locale_code]"
                        @input="storeStrings.updateString(record, locale_code)"
                    />
                    <lesli-button 
                        icon-only small danger icon="clear"
                        v-if="record[`translated_${locale_code}`] == true"  
                        @click="clearStringTranslation(record, locale_code)">
                    </lesli-button>
                    &nbsp;
                    <lesli-button 
                        icon-only small icon="save"
                        v-if="record[`translated_${locale_code}`] == true"  
                        @click="storeStrings.putString(record)">
                    </lesli-button>
                    &nbsp;
                    <lesli-button 
                        icon-only small icon="translate" 
                        v-if="!!record['en']"
                        @click="suggestTranslation(record, locale_code)">
                    </lesli-button>
                </td>
            </tr>
            <tr>
                <td></td>
                <td class="has-text-right">Context</td>
                <td>
                    <input 
                        type="text"
                        class="input"
                        placeholder="Add translation context..."
                        v-model="record.context"
                        @input="storeStrings.updateString(record)"
                    />
                </td>
            </tr>
            <tr>
                <td></td>
                <td class="has-text-right">Full path</td>
                <td>
                    <button 
                        class="button is-primary is-inverted" 
                        @click.stop="copyToClipboard($event, record.path)">
                        <span class="icon has-text-grey">
                            <span class="material-icons">
                                content_copy
                            </span>
                        </span>
                        <span>
                            {{ record.path }}
                        </span>
                    </button>
                </td>
            </tr>
            <tr>
                <td colspan="100%">
                    <div class="buttons is-justify-content-center">
                        <button 
                            class="button is-primary is-small"
                            @click="copyToClipboard($event, getLabelLink(record.id))">
                            <span class="icon is-small">
                                <span class="material-icons">link</span>
                            </span>
                            <span>Copy link</span>
                        </button>

                        <lesli-button 
                            small info solid icon="help_outline"
                            @click="askForHelp(record)">
                            Need help
                        </lesli-button>

                        <lesli-button 
                            small warning solid icon="translate"
                            @click="askForTranslation(record)">
                            Need translation
                        </lesli-button>
                    </div>
                </td>
            </tr>
        </template>
    </lesli-table>
</template>
