<script setup>
/*
Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
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
    <lesli-application-container>
        <lesli-header :title="storeModule.code">
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
                Add new string to translate
            </template>
            <template #default>
                <formStringNew v-if="storeModule.id" :module-id="storeModule.id">
                </formStringNew>        
            </template>
        </lesli-panel>
    </lesli-application-container>
</template>
