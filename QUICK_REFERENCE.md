# Quick Reference: Reward Points Discount System

## System Overview

**Purpose:** Allow users to redeem accumulated reward points as discount during checkout (1 point = ₹1 rupee)

**Flow:** 
1. User views cart with available rewards
2. User enters points to redeem
3. System calculates discount in real-time
4. User proceeds to payment with discount applied
5. Backend validates, creates order, updates rewards

---

## How It Works - Step by Step

### 📱 Mobile App (Flutter)

```
1. PAGE LOAD
   └─ initState() → _fetchUserRewardPoints()
      └─ Calls POST /uprofile_edit
         └─ Displays available reward balance

2. USER INPUT
   └─ User types reward points (e.g., 50)
      └─ onChange() → _calculateDiscount()
         ├─ Check: points ≥ 0 ✓
         ├─ Check: points ≤ available ✓
         ├─ Calculate: discount = points (1:1)
         └─ Update UI: Show cost breakdown

3. COST BREAKDOWN SHOWS
   ├─ Original Total: ₹100.00
   ├─ Discount: -₹50.00 (if points entered)
   └─ Final Amount: ₹50.00 (green)

4. PAYMENT CLICK
   └─ _navigateToPayment()
      ├─ Extract: pointsUsed = 50
      ├─ Extract: discountAmount = 50.00
      └─ Navigate to RazorpayScreen(50, 50.00)

5. PAYMENT PAGE
   └─ User selects Online/Offline
      └─ Click Pay/Confirm
         └─ updatepaymentstatus()
            └─ POST /place_order with:
               ├─ uid
               ├─ reward_points_used: 50
               └─ discount_amount: 50.00
```

### 🖥️ Backend (Django)

```
1. RECEIVE PAYMENT REQUEST
   └─ place_order(request)
      ├─ uid = 123
      ├─ reward_points_used = 50
      └─ discount_amount = 50.00

2. VALIDATION LAYER
   ├─ Find user in DB ✓
   ├─ Read user.rewards = 250
   ├─ Check: 50 ≤ 250 ✓
   ├─ Check: 50 == 50 (fraud check) ✓
   └─ Calculate: final = 100 - 50 = 50 ✓

3. CREATE ORDER
   ├─ New order record:
   │  ├─ USER_id = 123
   │  ├─ amount = 50 (FINAL, not original)
   │  └─ status = "completed"
   └─ For each cart item:
      └─ Create ordersub record

4. CALCULATE REWARDS
   ├─ Deduct used: 250 - 50 = 200
   ├─ Earn points: 50 + (50 × 0.1) = 55
   └─ Final balance: 200 + 55 = 255

5. UPDATE DATABASE
   ├─ user.rewards = 255
   └─ Clear cart items

6. RETURN RESPONSE
   {
     "order_id": 789,
     "original_amount": 100.00,
     "discount_applied": 50.00,
     "final_amount": 50.00,
     "reward_points_used": 50,
     "credit_points_earned": 55,
     "total_rewards": 255
   }

7. BACK TO APP
   └─ Navigator.pop(true)
      └─ Cart page refreshes
         └─ Cart empty, rewards updated
```

---

## API Reference

### Endpoint: POST `/uprofile_edit`
**Purpose:** Fetch user profile including reward points

**Request:**
```
POST /uprofile_edit
Content-Type: application/x-www-form-urlencoded

uid=123
```

**Response:**
```json
{
  "data": [
    {
      "id": 123,
      "username": "john_doe",
      "rewards": "250",
      ...
    }
  ]
}
```

---

### Endpoint: POST `/place_order`
**Purpose:** Create order with reward discount applied

**Request (OLD):**
```
POST /place_order
Content-Type: application/x-www-form-urlencoded

uid=123&payment_id=pay_123&total_amount=100
```

**Request (NEW - with rewards):**
```
POST /place_order
Content-Type: application/x-www-form-urlencoded

uid=123
payment_id=pay_123
total_amount=100.00
reward_points_used=50
discount_amount=50.00
```

**Response:**
```json
{
  "status": "ok",
  "order_id": 789,
  "payment_id": "pay_123",
  "original_amount": "100.00",
  "discount_applied": 50.0,
  "final_amount": 50.0,
  "reward_points_used": 50,
  "credit_points_earned": 55,
  "total_rewards": 255
}
```

**Error Response (Insufficient Balance):**
```json
{
  "status": "error",
  "message": "Insufficient reward points. Available: 30, Requested: 50"
}
```

**Error Response (Fraud Detected):**
```json
{
  "status": "error",
  "message": "Discount amount does not match reward points"
}
```

---

## Calculation Examples

### Example 1: Using 20 Points
```
Scenario:
- Available rewards: 250 points
- Original order: ₹100
- User enters: 20 points

Calculation:
- Discount: 20 × 1 = ₹20.00
- Final amount: ₹100 - ₹20 = ₹80
- Points earned: 80 + (80 × 0.1) = 88
- Rewards after: 250 - 20 + 88 = 318

Display (on app):
  Subtotal: ₹100.00
  Discount: -₹20.00
  Final: ₹80.00
  
  Available: 250 → 318 points
```

### Example 2: Using All Points
```
Scenario:
- Available rewards: 100 points
- Original order: ₹150
- User enters: 100 points

Calculation:
- Discount: 100 × 1 = ₹100.00
- Final amount: ₹150 - ₹100 = ₹50
- Points earned: 50 + (50 × 0.1) = 55
- Rewards after: 100 - 100 + 55 = 55

Display (on app):
  Subtotal: ₹150.00
  Discount: -₹100.00
  Final: ₹50.00
  
  Available: 100 → 55 points
```

### Example 3: No Discount
```
Scenario:
- Available rewards: 50 points
- Original order: ₹75
- User enters: 0 points (or nothing)

Calculation:
- Discount: 0
- Final amount: ₹75 - ₹0 = ₹75
- Points earned: 75 + (75 × 0.1) = 82.50 → 82
- Rewards after: 50 - 0 + 82 = 132

Display (on app):
  Subtotal: ₹75.00
  (Discount row not shown)
  Final: ₹75.00
  
  Available: 50 → 132 points
```

---

## Validation Rules

### Frontend Validation
```
Input Validation:
- Only numbers allowed (keyboardType: TextInputType.number)
- No negative numbers accepted
- Cannot exceed available balance
- On invalid input: Show error, keep previous values

Real-time Updates:
- onChange callback calculates discount immediately
- UI updates with cost breakdown
- Shows discount amount only when > 0
```

### Backend Validation
```
Security Checks:
1. User must exist in database
2. Reward points cannot exceed available balance
3. Discount amount must match points (1:1 ratio)
4. Final amount cannot be negative

Error Messages:
- "User not found" → 404
- "Insufficient reward points..." → 400
- "Discount amount does not match..." → 400
- Other exceptions → 500
```

---

## Database Changes

### order Table
**Column `amount`:**
- **Old behavior:** Stored original amount
- **New behavior:** Stores final amount AFTER discount

**Example:**
```
Original amount: ₹100
Discount: ₹30
Database stored: ₹70 (final amount)
```

### user Table
**Column `rewards`:**
- Updated atomically in single transaction
- Formula: `new_value = old - used + earned`
- Safe guards: never goes below 0 with `max(0, ...)`

---

## User Experience Flow

```
Step 1: VIEW CART
┌─────────────────────────────────┐
│ Cart Items:                      │
│ - Product 1 × 2 = ₹50           │
│ - Product 2 × 1 = ₹50           │
│ Total: ₹100                      │
│                                  │
│ 🎁 Your Reward Points: 250       │
│ [Enter points to redeem...] [?]  │
│                                  │
│ Subtotal: ₹100.00                │
│ Final Amount: ₹100.00            │
│                                  │
│ [💳 Proceed to Payment]          │
└─────────────────────────────────┘

Step 2: ENTER REWARD POINTS
┌─────────────────────────────────┐
│ Cart Items:                      │
│ - Product 1 × 2 = ₹50           │
│ - Product 2 × 1 = ₹50           │
│ Total: ₹100                      │
│                                  │
│ 🎁 Your Reward Points: 250       │
│ [  50  ] points to redeem        │
│ Discount: -₹50.00                │
│                                  │
│ Subtotal: ₹100.00                │
│ Discount: -₹50.00 (green)        │
│ ─────────────────                │
│ Final Amount: ₹50.00 (green)     │
│                                  │
│ [💳 Proceed to Payment]          │
└─────────────────────────────────┘

Step 3: PAYMENT PAGE
┌─────────────────────────────────┐
│ Order Summary:                   │
│ - Cart Total: ₹100               │
│ - Discount: -₹50                 │
│ - Final Amount: ₹50              │
│                                  │
│ Payment Method:                  │
│ ◉ Online Payment (Razorpay)      │
│ ○ Offline Payment                │
│                                  │
│ [💳 Pay ₹50 Online]              │
│ [✓ Confirm Offline Booking]      │
└─────────────────────────────────┘

Step 4: SUCCESS
✓ Order placed successfully!
✓ Reward points used: 50
✓ Points earned: 88
✓ New balance: 288 (250 - 50 + 88)
✓ Cart cleared
✓ Back to home page
```

---

## Troubleshooting

### Problem: Points not displaying
**Solution:** Check if `/uprofile_edit` endpoint works and returns `rewards` field

### Problem: Discount not calculating
**Solution:** Ensure `_calculateDiscount()` is called on text change, check input validation

### Problem: Order fails with discount error
**Solution:** Verify `discount_amount == reward_points_used` on backend

### Problem: Rewards not updating
**Solution:** Check database transaction was committed, verify `user.save()` called

### Problem: Cart not clearing after order
**Solution:** Ensure `cart_items.delete()` is called in `place_order()`

---

## Performance Notes

- Reward points fetched once on page load (cached)
- Discount calculation is instant (no network call)
- Order creation sends single POST request
- No database queries during calculation
- Cart delete is bulk operation (efficient)

---

## Security Summary

✅ Frontend validates before sending
✅ Backend validates again (never trust client)
✅ Fraud check: discount == points
✅ Balance check: available >= requested
✅ Amount check: final ≥ 0
✅ Atomic transaction: all or nothing
✅ Audit trail: original amount stored in calculation

