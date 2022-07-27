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
        require: false
    }
})


// · 
onMounted(() => {
    storeStrings.fetchRelevant()
    storeTranslations.fetchOptions()
})


// · 
const columns = ref([])


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
    for(let locale in storeTranslations?.options?.locales_available) {
        columns.value.push({
            label: storeTranslations?.options?.locales_available[locale],
            field: locale
        })
    }
}


// · watch for the locales available to dynamically show language columns in the editor
watch(() => storeTranslations.options.locales_available, () => {
    resetColumns()
})


// · watch for the prop, so the editor show only one language at the time
watch(() => props.locale, () => {

    // reset means the user selected to work with all the languages
    if (props.locale == 'reset') {
        return resetColumns()
    }

    // show initial columns
    initColumns()

    // push the column with the language selected by the user
    columns.value.push({
        label: storeTranslations?.options?.locales_available[props.locale],
        field: props.locale,
        width: '100%'
    })

})


// · 
function copyToClipboard(string) {
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
}


// · 
function putString(string) {
    storeStrings.putString(string)
}


</script>
<template>
    <lesli-table
        :loading="storeStrings.relevant.loading"
        :records="storeStrings.relevant.records"
        :columns="columns">
        <template #label="{ value }">
            <button 
                class="button is-text is-paddingless" 
                @click="copyToClipboard('hola')">
                {{ value }}
            </button>
        </template>
        <template #[locale_code]="{ value, row }"
            v-for="(locale_name, locale_code, index) in storeTranslations.options.locales_available">
            <input 
                type="text"
                class="input"
                @input="putString(row)"
                v-model="row[locale_code]"
            />
        </template>
    </lesli-table>
</template>
