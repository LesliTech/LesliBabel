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
import { useStrings } from "CloudBabel/stores/strings"
import { useTranslations } from "CloudBabel/stores/translations"
import { useServiceTranslator } from "LesliVue/stores/services/translator"


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


// · editor columns
const columns = ref([])


// · 
const language = ref(null)


// · 
const languageSource = ref('label')


// · 
onMounted(() => {

    // english by default if custom language not sent through url
    language.value = route.query?.locale ?? 'en'

    // get options for translations
    storeTranslations.fetchOptions()

})


// · get translations
function fetchTranslations() {

    // work with an specific module if provided
    if (props.module) {
        storeStrings.module = props.module
        storeStrings.fetchStrings()
    }

    // work with relevant translations
    if (!props.module) {
        storeStrings.module = 0
        storeStrings.fetchRelevant()
    }

}


// · load only the necessary columns for the editor
function initColumns() {
    columns.value = []
    columns.value.push({
        label: 'Label to translate',
        field: 'label'
    })
}


// · load all the columns available for the editor
function resetColumns() {

    // load initial static columns
    initColumns()

    // dynamic add the column related to the selected working language
    columns.value.push({
        label: storeTranslations?.options?.locales_available[language.value],
        field: language.value,
        width: '100%'
    })
}


// · update strings through the store
function putString(string) {
    storeStrings.putString(string)
}


// · 
function renderColumns() {

    // reset means the user selected to work with all the languages
    if (language.value == 'reset') {
        return resetColumns()
    }

    // show initial columns
    initColumns()

    // push the column with the language selected by the user
    columns.value.push({
        label: storeTranslations?.options?.locales_available[language.value],
        field: language.value,
        width: '100%'
    })
}


// · build the title for the table custom headers
function languageHead(language) {
    return 'head('+language+')'
}


// · watch for the locales available to dynamically show language columns in the editor
watch(() => storeTranslations.options.locales_available, () => {
    resetColumns()
})


// · get strings for the module selected
watch(() => props.module, () => {
    storeStrings.search = ""
    storeStrings.module = props.module
    fetchTranslations()
})


// · go to the first input once translations loaded
watch(() => storeStrings.strings.records, () => {
    setTimeout(() => { nextTranslation() }, 1000) 
})


// · changing the working language
watch(() => language.value, (language) => {
    storeStrings.language = language
    fetchTranslations()
    resetColumns()
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


// suggest translation from english to desire language
// to make this work we need to have the label translated to english already
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
</script>
<template>
    <lesli-table
        id="babel-translations"
        :loading="storeStrings.strings.loading"
        :records="storeStrings.strings.records"
        :columns="columns"
        @paginate="storeStrings.fetchStrings()"
        @details="nextTranslation()">

        <!-- 
            Table custom header
        -->
        <template #[languageHead(language)]="{ column }">
            <lesli-select
                icon="public"
                v-model="language"
                :options="storeTranslations.locales">
            </lesli-select>
        </template>


        <!-- 
            Table custom cells
        -->
        <template #label="{ record }">
            <button 
                class="button is-white p-0" 
                @click.stop="copyToClipboard($event, record.label)"
                @contextmenu.capture.prevent="copyToClipboard($event, record.path)">
                {{ record[languageSource] }}
            </button>
        </template>
        
        <template #[language]="{ value, record }">
            <input 
                type="text"
                class="input"
                placeholder="Add translations..."
                @input="updateString(record)"
                v-model="record[language]"
            />
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
                        @change="test(record)"
                        @input="updateString(record)"
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
                        @click="putString(record, false)">
                    </lesli-button>
                    &nbsp;
                    <lesli-button icon-only small icon="translate" @click="suggestTranslation(record, locale_code)">
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
                    />
                </td>
            </tr>
            <tr>
                <td></td>
                <td class="has-text-right">Full path</td>
                <td>
                    <button class="button is-primary is-inverted" @click.stop="copyToClipboard($event, record.path)">
                        {{ record.path }}
                    </button>
                </td>
            </tr>
        </template>
    </lesli-table>
</template>
