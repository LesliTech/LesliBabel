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


</script>
<template>
    <section class="application-component">
        <lesli-header title="Relevant translations">
            <component-actions></component-actions>
        </lesli-header>

        <component-label-editor module="relevants">
        </component-label-editor>
    </section>
</template>
