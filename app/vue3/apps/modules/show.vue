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


// · import components
import formLabelNew from "CloudBabel/components/form-label-new.vue"
import formLabelEditor from "CloudBabel/components/form-label-editor.vue"


// · import lesli stores
import { useModule } from "CloudBabel/stores/module"
import { useStrings } from "CloudBabel/stores/strings"
import { useTranslations } from "CloudBabel/stores/translations"


// · implement stores
const storeModule = useModule()
const storeStrings = useStrings()
const storeTranslations = useTranslations()
const router = useRouter()
const route = useRoute()


// · 
const language = ref({})


// · 
function getModule() {
    return route.params?.id
}

onMounted(() => {
    storeModule.fetchModule(route.params.id)
})

// · 
watch(() => route.params.id, () => {
    storeModule.fetchModule(route.params.id)
})


</script>
<template>
    <section class="application-component">
        <lesli-header :title="storeModule.name"></lesli-header>
        <lesli-toolbar @search="storeStrings.fetchSearch">
            <lesli-select
                reset="all"
                icon="public"
                v-model="language"
                :options="storeTranslations.locales">
            </lesli-select>
        </lesli-toolbar>
        <formLabelEditor :locale="language.value" :module="getModule()">
        </formLabelEditor>
    </section>
</template>
