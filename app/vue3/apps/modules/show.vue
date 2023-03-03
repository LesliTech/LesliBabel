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
import formStringNew from "CloudBabel/components/form-string-new.vue"
import formLabelEditor from "CloudBabel/components/form-label-editor.vue"
import componentActions from "CloudBabel/components/actions.vue"


// · import lesli stores
import { useModule } from "CloudBabel/stores/module"
import { useStrings } from "CloudBabel/stores/strings"


// · implement stores
const storeModule = useModule()
const storeStrings = useStrings()
const router = useRouter()
const route = useRoute()


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
        <lesli-header :title="storeModule.name">
            <component-actions></component-actions>
            <lesli-button icon="add" @click="storeStrings.showPanel = true">
                add new string
            </lesli-button>
        </lesli-header>

        <lesli-toolbar @search="storeStrings.fetchSearch">
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
