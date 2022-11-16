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


// · import lesli stores
import { useStrings } from "CloudBabel/stores/strings"
import { useTranslations } from "CloudBabel/stores/translations"


// · implement stores
const storeStrings = useStrings()
const storeTranslations = useTranslations()


// · 
const props = defineProps({
    locale: {
        type: String,
        require: false,
        default: I18n.locale
    }, 
    module: {
        type: [Number, String],
        require: false
    }
})


// · 
const columns = ref([])


// · 
const language = ref('de')


// · 
const languageSource = ref('label')


// · 



// · 
onMounted(() => {
    fetch()
    storeTranslations.fetchOptions()
    setTimeout(() => renderColumns(), 1000)
    
})


// · 
function fetch() {
    storeStrings.module = props.module
    if (props.module) { storeStrings.fetch() }
    if (!props.module) { storeStrings.fetchRelevant() }
}


// · load only the necessary columns for the editor
function initColumns() {
    columns.value = []
    columns.value.push({
        label: 'Label',
        field: 'label'
    })
}


// · load all the columns available for the editor
function resetColumns() {
    initColumns()
    columns.value.push({
        label: storeTranslations?.options?.locales_available[language.value],
        field: language.value,
        width: '100%'
    })
}


// · 
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


// · 
function languageHead(language) {
    return 'head('+language+')'
}


// · watch for the locales available to dynamically show language columns in the editor
watch(() => storeTranslations.options.locales_available, () => {
    resetColumns()
})


// · 
watch(() => props.module, () => fetch())


// · 
watch(() => storeStrings.relevant.records, () => {
    setTimeout(() => { nextTranslation() }, 1000) 
})


// · changin the working language
watch(() => language.value, (language) => {
    storeStrings.language = language
    fetch()
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

</script>
<template>
    <lesli-table
        id="babel-translations"
        :loading="storeStrings.relevant.loading"
        :records="storeStrings.relevant.records"
        :columns="columns">

        <!-- 
            Table custom header
        -->
        <template #head(label)="{ column }">
            <lesli-select
                icon="public"
                v-model="languageSource"
                :options="storeTranslations.localeSource">
            </lesli-select>
        </template>
        
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
                class="button is-white px-2 py-0" 
                @click.stop="copyToClipboard($event, record.label)"
                @contextmenu.capture.prevent="copyToClipboard($event, record.path)">
                {{ record[languageSource] }}
            </button>
        </template>
        
        <template #[language]="{ value, record }">
            <input 
                type="text"
                class="input"
                @input="putString(record)"
                v-model="record[language]"
            />
        </template>

        <template #detail="{ record }">

            <button 
                class="button is-ghost px-0 mb-2" 
                @click.stop="copyToClipboard($event, record.path)">
                path: {{ record.path }}
            </button>
            <div class="message mb-4">
                <div class="message-body">
                    <p v-for="(locale_name, locale_code) in storeTranslations.options.locales_available">
                        {{locale_name}}: {{ record[locale_code] }}
                    </p>
                </div>
            </div>
            <p v-if="record.context">context: {{ record.context }}</p>
        </template>
    </lesli-table>
</template>
<style>

table.lesli-table thead th, 
table.lesli-table thead td,
table.lesli-table tbody th,
table.lesli-table tbody td {
    padding: .8rem 1rem;
}

table.lesli-table thead th {
    padding-left: 1.6rem;
}

table.lesli-table tbody .buttons {
    flex-wrap: nowrap;
}

table input.input {
    border: none;
    box-shadow: none;
    border-radius: 3px;
    background-color: transparent;
}

.copied:after{
    display: inline;
    position: absolute;
    content: "Label copied to clipboard!";
    animation: 1s ease-in-out 0s 1 normal forwards running copyit;
    font-size: .8em;
}

@keyframes copyit{ 
    0%{ bottom:2em;opacity:1;} 
    100%{bottom:4em;opacity:0;} 
}

</style>
