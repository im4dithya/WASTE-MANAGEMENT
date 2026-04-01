# Reward Points Discount Implementation

## Overview
This document describes the implementation of reward points redemption during checkout, allowing users to apply accumulated reward points (1 point = 1 rupee) as discount on their purchases.

## Implementation Summary

### 1. Flutter Frontend Changes

#### File: `view_cart_and_pay.dart`

**State Variables Added:**
```dart
int userRewardPoints = 0;
TextEditingController rewardPointsController = TextEditingController();
double discountAmount = 0;
double finalAmount = 0;
```

**initState() Method Added:**
- Calls `_fetchUserRewardPoints()` on page load to fetch user's current reward balance

**_fetchUserRewardPoints() Method:**
- Fetches user profile from `/uprofile_edit` endpoint
- Extracts rewards field and updates `userRewardPoints` state variable

**_calculateDiscount() Method:**
- Called when user enters reward points in the text field
- Validates:
  - Points cannot be negative
  - Points cannot exceed user's available balance
- Calculates discount as: `discountAmount = pointsToUse * 1` (1 point = 1 rupee)
- Updates `finalAmount = totalAmount - discountAmount` (min 0)
- Shows error snackbar for invalid input

**UI Changes:**
- Added reward points section in cart bottom showing:
  - Available reward points: `🎁 Your Reward Points: {userRewardPoints}`
  - Input field: "Enter points to redeem (1 point = ₹1)"
  - Discount display: "Discount: -₹{discountAmount}"
  
- Added final amount breakdown section showing:
  - Subtotal: ₹{totalAmount}
  - Discount: -₹{discountAmount} (if applicable)
  - Final Amount: ₹{finalAmount} (bold, green)

**_navigateToPayment() Method Updated:**
- Extracts reward points from `rewardPointsController.text`
- Passes to RazorpayScreen constructor:
  - `discountAmount`: The calculated discount
  - `rewardPointsUsed`: Number of points redeemed

#### File: `RazorpayScreen.dart`

**Constructor Updated:**
```dart
class RazorpayScreen extends StatefulWidget {
  final double discountAmount;
  final int rewardPointsUsed;

  RazorpayScreen({
    this.discountAmount = 0,
    this.rewardPointsUsed = 0,
  });
}
```

**updatepaymentstatus() Method Updated:**
- Now calls `/place_order` endpoint instead of `/user_bookschedule`
- Passes:
  - `uid`: User ID from SharedPreferences
  - `reward_points_used`: Reward points to deduct from user
  - `discount_amount`: Discount amount applied
- Handles success response with order details
- Navigates back with success flag (true) to refresh cart

**Import Addition:**
- Added `import 'dart:convert';` for JSON parsing

---

### 2. Django Backend Changes

#### File: `myapp/views.py` - place_order() Function

**New Parameters Accepted:**
- `reward_points_used`: (int) Number of reward points to redeem
- `discount_amount`: (float) Discount amount in rupees
- `payment_id`: Now optional (defaults to 'TEST_PAYMENT_ID' for web testing)

**Validation Implemented:**
1. **User Existence Check**: Verifies user exists in database
2. **Reward Balance Validation**:
   - Checks if `reward_points_used <= current_rewards`
   - Returns error if insufficient balance
3. **Fraud Prevention**:
   - Validates `discount_amount == reward_points_used` (1:1 ratio)
   - Returns error if discount doesn't match points (security check)

**Discount Application Logic:**
```python
final_amount = max(0, total_amount - discount_amount)
```
- Ensures final amount cannot be negative
- Stores `final_amount` in order record

**Reward Points Calculation:**
```python
# Deduct used points
new_rewards = current_rewards - reward_points_used
# Add earned points from this order
new_rewards += credit_points + total_reward_points
# Ensure non-negative
new_rewards = max(0, new_rewards)
```

**Order Creation:**
- Stores final amount (after discount) in `order.amount` field
- Records all transaction details for auditing

**Response Fields Enhanced:**
```json
{
  "order_id": "...",
  "payment_id": "...",
  "original_amount": 100.00,
  "discount_applied": 20.00,
  "final_amount": 80.00,
  "reward_points_used": 20,
  "credit_points_earned": 89,
  "total_rewards": 150
}
```

---

## Data Flow

### User Checkout Flow:
1. **View Cart Page Load**
   - `initState()` calls `_fetchUserRewardPoints()`
   - Displays available reward balance to user

2. **User Enters Reward Points**
   - User types reward points in input field
   - `_calculateDiscount()` validates and calculates discount
   - UI updates to show discount breakdown

3. **User Proceeds to Payment**
   - `_navigateToPayment()` extracts points and discount
   - Navigates to `RazorpayScreen` with discount parameters

4. **Payment Processing**
   - User selects payment method (online/offline)
   - `updatepaymentstatus()` calls `/place_order` endpoint
   - Backend validates and applies discount

5. **Order Confirmation**
   - Order created with final amount (after discount)
   - User rewards updated (deducted used points + credited earned points)
   - Cart cleared
   - Navigation returns to cart page (auto-refresh)

---

## Validation & Security

### Frontend Validation:
- ✅ Non-negative points check
- ✅ Balance limit check (cannot exceed available points)
- ✅ Empty input handling

### Backend Validation:
- ✅ User existence check
- ✅ Reward balance verification
- ✅ Discount amount verification (1:1 ratio)
- ✅ Non-negative final amount (max(0, ...))
- ✅ Non-negative final rewards (max(0, ...))

### Fraud Prevention:
- Backend verifies discount_amount == reward_points_used to prevent tampering
- Points are only deducted after successful order creation
- All transactions logged in order record with original and final amounts

---

## Conversion Rate

**Reward Points to Cash Conversion:**
- 1 Reward Point = ₹1 Rupee (1:1 conversion)
- Can be redeemed any time during checkout
- Unused points remain in user account

**Credit Points Earned Per Order:**
- Base: 1 point per ₹1 spent (on final amount after discount)
- Bonus: 10% of final amount
- Item rewards: 10% of item quantity

Example:
- Original amount: ₹100
- Discount (20 points): -₹20
- Final amount: ₹80
- Credit points earned: 80 + 8 (bonus) = 88 points

---

## Error Handling

### Frontend:
- Invalid input → SnackBar message with available balance
- Network error → Error message displayed

### Backend:
- User not found → 404 error
- Insufficient balance → 400 error with available balance message
- Discount mismatch → 400 error
- Exception → 500 error with details

---

## Testing Checklist

- [ ] Fetch user rewards on cart page load
- [ ] Reward points input field shows validation errors
- [ ] Discount calculation is correct (1:1 ratio)
- [ ] Final amount reflects discount
- [ ] Backend accepts reward parameters
- [ ] Order is created with final amount
- [ ] User rewards are deducted and credited correctly
- [ ] Cart is cleared after successful order
- [ ] Out-of-stock validation still works
- [ ] Payment modes (online/offline) work correctly

---

## API Endpoints Used

### Flutter Calls:
- **POST `/uprofile_edit`**
  - Body: `uid`
  - Response: User profile including rewards field

- **POST `/place_order`**
  - Body: `uid`, `reward_points_used`, `discount_amount`
  - Response: Order details with credit points earned

### Expected Response (place_order):
```json
{
  "status": "ok",
  "message": "Order placed successfully",
  "order_id": 123,
  "payment_id": "pay_xyz123",
  "original_amount": "100.0",
  "discount_applied": 20.0,
  "final_amount": 80.0,
  "reward_points_used": 20,
  "credit_points_earned": 89,
  "total_rewards": 1850
}
```

---

## Files Modified

1. **Flutter:**
   - `lib/view cart and pay.dart` - Added reward UI and logic
   - `lib/RazorpayScreen.dart` - Updated to handle discount parameters

2. **Django:**
   - `myapp/views.py` - Updated place_order() function

---

## Future Enhancements

- [ ] Partial reward redemption UI (select amount to redeem)
- [ ] Reward points history/audit trail
- [ ] Reward expiration dates
- [ ] Tiered conversion rates (higher spending = better rate)
- [ ] Promotional bonuses (2x points for specific products)
- [ ] Reward leaderboard/achievements

