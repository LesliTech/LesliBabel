<script setup>

// · import lesli stores
import { useTranslations } from "CloudBabel/stores/translations"


// · implement stores
const storeTranslations = useTranslations()

</script>
<template>
    <div class="dropdown is-hoverable">
        <div class="dropdown-trigger">
            <button class="button is-primary is-outlined" aria-haspopup="true" aria-controls="dropdown-menu">
                <span class="icon is-small">
                    <span class="material-icons">
                        tune
                    </span>
                </span>
                <span>Options</span>
            </button>
        </div>
        <div class="dropdown-menu" id="dropdown-menu" role="menu">
            <div class="dropdown-content">
                <a class="dropdown-item" @click="storeTranslations.postRenovate()">
                    <span class="icon is-small">
                        <span class="material-icons">
                            download
                        </span>
                    </span>
                    <span>Update</span>
                </a>
                <a class="dropdown-item" @click="storeTranslations.postDeploy()">
                    <span class="icon is-small">
                        <span class="material-icons">
                            rocket_launch
                        </span>
                    </span>
                    <span>Deploy</span>
                </a>
                <a class="dropdown-item" @click="storeTranslations.postSync()">
                    <span class="icon is-small">
                        <span class="material-icons">
                            sync
                        </span>
                    </span>
                    <span>Sync</span>
                </a>
                <hr class="dropdown-divider">
                <a class="dropdown-item">
                    <span class="icon is-small">
                        <span class="material-icons">
                            download
                        </span>
                    </span>
                    <span>JavaScript</span>
                </a>
                <a class="dropdown-item">
                    <span class="icon is-small">
                        <span class="material-icons">
                            download
                        </span>
                    </span>
                    <span>Flutter</span>
                </a>
            </div>
        </div>
    </div>
</template>
