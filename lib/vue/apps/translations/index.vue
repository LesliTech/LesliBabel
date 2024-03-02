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
import { ref, reactive, onMounted, watch, computed, inject } from "vue"
import { useRouter, useRoute } from 'vue-router'


// · initialize/inject plugins
const router = useRouter()
const route = useRoute()
const msg = inject("msg")
const url = inject("url")


// · import components
import componentLabelEditor from "LesliBabel/vue/components/form-label-editor.vue"
import componentActions from "LesliBabel/vue/components/actions.vue"


// · import lesli stores
import { useStrings } from "LesliBabel/vue/stores/strings"
import { useTranslations } from "LesliBabel/vue/stores/translations"


// · implement stores
const storeStrings = useStrings()
const storeTranslations = useTranslations()


// · 
function search(string) {
    router.push({ path: "translations", query: { search: string }})
}
</script>
<template>
    <lesli-application-container>
        <lesli-header title="Translations">
            <component-actions></component-actions>
        </lesli-header>

        <lesli-toolbar :initial-value="storeStrings.search" @search="search">
        </lesli-toolbar>

        <component-label-editor>
        </component-label-editor>
    </lesli-application-container>
</template>
