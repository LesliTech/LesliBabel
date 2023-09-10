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
import formStringNew from "LesliBabel/components/form-string-new.vue"
import formLabelEditor from "LesliBabel/components/form-label-editor.vue"
import componentActions from "LesliBabel/components/actions.vue"


// · import lesli stores
import { useModule } from "LesliBabel/stores/module"
import { useStrings } from "LesliBabel/stores/strings"


// · implement stores
const storeModule = useModule()
const storeStrings = useStrings()
const router = useRouter()
const route = useRoute()


// · 
onMounted(() => {
    storeModule.fetchModule(route.params.id)
})


// · 
function getModule() {
    return route.params?.id
}


// · 
function search(string) {
    router.push({ query: { search: string }})
}


// · 
watch(() => route.params.id, () => {
    storeModule.fetchModule(route.params.id)
})

</script>
<template>
    <section class="application-component">
        <lesli-header :title="storeModule.name">
            <component-actions></component-actions>
            <lesli-button solid icon="add" @click="storeStrings.showPanel = true">
                add new string
            </lesli-button>
        </lesli-header>

        <lesli-toolbar @search="search">
        </lesli-toolbar>
        
        <formLabelEditor :module="getModule()">
        </formLabelEditor>

        <lesli-panel v-model:open="storeStrings.showPanel">
            <template #header>
                <span class="icon">
                    <span class="material-icons">
                        translate
                    </span>
                </span>
                Add new string to translate
            </template>
            <template #default>
                <formStringNew v-if="storeModule.id" :module-id="storeModule.id">
                </formStringNew>        
            </template>
        </lesli-panel>
    </section>
</template>
