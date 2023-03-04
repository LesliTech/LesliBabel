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


// · Import components
import componentActions from "CloudBabel/components/actions.vue"


// · initialize/inject plugins
const router = useRouter()
const msg = inject("msg")
const url = inject("url")


// · import lesli stores
import { useStatistics } from "CloudBabel/stores/statistics"
import { useStrings } from "CloudBabel/stores/strings"


// · implement stores
const storeStatistics = useStatistics()
const storeStrings = useStrings()


// · 
onMounted(() => {
    storeStatistics.fetch()
})


// · 
function flag(language) {
    if (language == 'en') { return 'flag-icon-gb' }
    if (language == 'uk') { return 'flag-icon-ua' }
    return 'flag-icon-'+language
}


</script>
<template>
    <section class="application-component">
        <lesli-header :title="`Found ${ storeStatistics.totalStrings } registered labels`">
            <component-actions></component-actions>
        </lesli-header>

        <lesli-toolbar @search="storeStrings.fetch"></lesli-toolbar>

        <div class="locales mt-2">
            <router-link class="card mr-5" 
                v-for="locale in storeStatistics.languages" 
                :key="locale.code"
                :to="url.babel('translations', { locale: locale.code }).s" >
                <span :class="['mb-2', 'is-size-2','flag-icon', flag(locale.code)]"></span>
                <p class="is-size-5">
                    {{ locale.name }}: {{ locale.total }}
                </p>
                <small>
                    missing: {{ storeStatistics.totalStrings - locale.total }} translations
                </small>
            </router-link>
        </div>

    </section>
</template>
