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


// · import components
import formLabelNew from "CloudBabel/components/form-label-new.vue"
import formLabelEditor from "CloudBabel/components/form-label-editor.vue"


// · import lesli stores
import { useStrings } from "CloudBabel/stores/strings"


// · implement stores
const storeStrings = useStrings()

const language = ref({})

const languages = [{
    label: 'english',
    value: 'en'
}]

// · 
onMounted(() => {

})


</script>
<template>
    <section class="application-component">
        <lesli-header title="Translations"></lesli-header>
        <lesli-toolbar @search="storeStrings.fetch">
            <lesli-select
                icon="public"
                v-model="language"
                :options="languages">
            </lesli-select>
        </lesli-toolbar>

        <formLabelEditor>
        </formLabelEditor>

    </section>
</template>
