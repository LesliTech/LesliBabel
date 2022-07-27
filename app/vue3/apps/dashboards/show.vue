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
import { useTranslations } from "CloudBabel/stores/translations"
import { useStatistics } from "CloudBabel/stores/statistics"
import { useStrings } from "CloudBabel/stores/strings"


// · implement stores
const storeTranslations = useTranslations()
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
            <div class="dropdown is-right is-hoverable">
                <div class="dropdown-trigger">
                    <button class="button" aria-haspopup="true" aria-controls="dropdown-menu">
                        <span>Options</span>
                        <span class="icon is-small">
                            <i class="fas fa-angle-down" aria-hidden="true"></i>
                        </span>
                    </button>
                </div>
                <div class="dropdown-menu" id="dropdown-menu" role="menu">
                    <div class="dropdown-content">
                        <a class="dropdown-item" @click="storeTranslations.postRenovate()">
                            <span class="icon">
                                <span class="material-icons">
                                    download
                                </span>
                            </span>
                            <span>Update translations</span>
                        </a>
                        <a class="dropdown-item" @click="storeTranslations.postDeploy()">
                            <span class="icon">
                                <span class="material-icons">
                                    rocket_launch
                                </span>
                            </span>
                            <span>Deploy to Rails</span>
                        </a>
                    </div>
                </div>
            </div>
        </lesli-header>
        <lesli-toolbar @search="storeStrings.fetch"></lesli-toolbar>

        <div class="columns mt-2">
            <div class="column" v-for="locale in storeStatistics.languages" :key="locale.code">
                <div class="card translations-stats pt-1" @click="showLanguage(locale.code)">
                    <div class="card-content has-text-centered">
                        <span :class="['mb-2', 'is-size-2','flag-icon', flag(locale.code)]"></span>
                        <p class="is-size-5">
                            {{ locale.name }}: {{ locale.total }}
                        </p>
                        <small>
                            missing: {{ storeStatistics.totalStrings - locale.total }} translations
                        </small>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>
