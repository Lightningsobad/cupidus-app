# Story 4.1: Love Pet Adoption

Status: done

## Story

As a **Couple**,
We want to **adopt a virtual pet**,
So that **we have a shared responsibility that grows with our relationship**.

## Acceptance Criteria

1. **Given** the couple has been paired for 24 hours
   - **When** they open the Love Pet tab
   - **Then** they see an "Adoption Center" with options (Cat, Dog, Bunny)

2. **Given** they select a pet
   - **When** they name it and confirm
   - **Then** the pet appears on the dashboard of BOTH users

## Tasks / Subtasks

- [x] Backend: Create `PetModule` (AC: #1, #2)
  - [x] Entity: `Pet` (id, coupleId, species, name, happiness, level, lastInteraction, createdAt)
  - [x] Enum: `PetSpecies` (CAT, DOG, BUNNY)
  - [x] DTO: `AdoptPetDto` (species, name)
  - [x] Service: Adopt pet (validate pairing 24h), get couple's pet, update happiness
  - [x] Controller: `POST /pets/adopt`, `GET /pets`
- [x] Backend: Unit Tests
  - [x] `pets.service.spec.ts`: Adopt, get, 24h pairing validation
- [x] iOS: Adoption Center UI (AC: #1)
  - [x] `PetViewModel`: state, pet data, adoption flow
  - [x] `AdoptionCenterView`: species selection with animated cards
  - [x] `PetDashboardView`: pet display with happiness meter
- [x] Sprint status updates
