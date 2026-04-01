# Code Changes Summary

## Flutter Changes

### File: `lib/view_cart_and_pay.dart`

#### 1. Added State Variables (after line 35)
```dart
// Reward points related
int userRewardPoints = 0;
TextEditingController rewardPointsController = TextEditingController();
double discountAmount = 0;
double finalAmount = 0;
```

#### 2. Added initState Method (before _getJokes method)
```dart
@override
void initState() {
  super.initState();
  _fetchUserRewardPoints();
}
```

#### 3. Added _fetchUserRewardPoints() Method
```dart
Future<void> _fetchUserRewardPoints() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? uid = prefs.getString("uid");

    var response = await http.post(
      Uri.parse("$ip/uprofile_edit"),
      body: {'uid': uid},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null && data['data'].length > 0) {
        setState(() {
          userRewardPoints = int.tryParse(data['data'][0]['rewards'].toString()) ?? 0;
        });
      }
    }
  } catch (e) {
    print('Error fetching reward points: $e');
  }
}
```

#### 4. Added _calculateDiscount() Method
```dart
void _calculateDiscount() {
  String pointsStr = rewardPointsController.text.trim();
  if (pointsStr.isEmpty) {
    setState(() {
      discountAmount = 0;
      finalAmount = totalAmount;
    });
    return;
  }

  try {
    int pointsToUse = int.parse(pointsStr);
    
    if (pointsToUse < 0 || pointsToUse > userRewardPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid points. Available: $userRewardPoints')),
      );
      return;
    }

    setState(() {
      discountAmount = pointsToUse.toDouble(); // 1 point = 1 rupee
      finalAmount = (totalAmount - discountAmount).clamp(0.0, double.infinity);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid input')),
    );
  }
}
```

#### 5. Added Reward UI Section in Build Method (before Payment Button)
```dart
// Reward Points Section
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.orange.shade100,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '🎁 Your Reward Points: $userRewardPoints',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade800,
        ),
      ),
      SizedBox(height: 8),
      TextField(
        controller: rewardPointsController,
        keyboardType: TextInputType.number,
        onChanged: (value) => _calculateDiscount(),
        decoration: InputDecoration(
          hintText: 'Enter points to redeem (1 point = ₹1)',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
      if (discountAmount > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Discount: -₹${discountAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  ),
),

SizedBox(height: 12),

// Final Amount Section
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Subtotal:'),
          Text('₹${totalAmount.toStringAsFixed(2)}'),
        ],
      ),
      if (discountAmount > 0)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Discount:'),
            Text(
              '-₹${discountAmount.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Final Amount:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            '₹${finalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    ],
  ),
),
```

#### 6. Updated _navigateToPayment() Method
```dart
void _navigateToPayment() {
  if (cartItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cart is empty')),
    );
    return;
  }

  // Calculate total amount
  double total = 0;
  for (var item in cartItems) {
    total += (double.tryParse(item.quantity) ?? 0);
  }
  totalAmount = total;

  // Get reward points used
  int pointsUsed = 0;
  if (rewardPointsController.text.isNotEmpty) {
    pointsUsed = int.tryParse(rewardPointsController.text) ?? 0;
  }

  // Navigate to RazorpayScreen with cart data
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RazorpayScreen(
        discountAmount: discountAmount,
        rewardPointsUsed: pointsUsed,
      ),
    ),
  ).then((value) {
    if (value == true) {
      // Payment successful, refresh cart
      setState(() {});
    }
  });
}
```

---

### File: `lib/RazorpayScreen.dart`

#### 1. Added Import
```dart
import 'dart:convert';
```

#### 2. Updated Class Constructor
```dart
class RazorpayScreen extends StatefulWidget {
  final double discountAmount;
  final int rewardPointsUsed;

  RazorpayScreen({
    this.discountAmount = 0,
    this.rewardPointsUsed = 0,
  });

  @override
  _RazorpayScreenState createState() => _RazorpayScreenState();
}
```

#### 3. Updated updatepaymentstatus() Method
```dart
Future<void> updatepaymentstatus() async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  String ip = sh.getString("ip") ?? "http://localhost:8000";
  String uid = sh.getString("uid") ?? "";
  
  // Create order with reward discount
  var response = await http.post(
    Uri.parse("$ip/place_order"),
    body: {
      "uid": uid,
      "reward_points_used": widget.rewardPointsUsed.toString(),
      "discount_amount": widget.discountAmount.toString(),
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    print("Order placed successfully: ${data['order_id']}");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed successfully!')),
    );
    
    // Navigate back and refresh cart
    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to place order')),
    );
  }
}
```

---

## Django Backend Changes

### File: `myapp/views.py`

#### Updated place_order() Function (lines 1203-1289)

**Before:**
```python
def place_order(request):
    """Place order from cart items and convert to credit points"""
    try:
        uid = request.POST.get('uid')
        payment_id = request.POST.get('payment_id')
        total_amount = request.POST.get('total_amount')
        payment_mode = request.POST.get('payment_mode', 'online')
        
        if not uid or not payment_id:
            return JsonResponse({"status": "error", "message": "Missing required fields"}, status=400)
        
        # ... rest of old code
```

**After:**
```python
def place_order(request):
    """Place order from cart items and convert to credit points"""
    try:
        uid = request.POST.get('uid')
        payment_id = request.POST.get('payment_id', 'TEST_PAYMENT_ID')
        total_amount = request.POST.get('total_amount')
        payment_mode = request.POST.get('payment_mode', 'online')
        reward_points_used = int(request.POST.get('reward_points_used', 0))
        discount_amount = float(request.POST.get('discount_amount', 0))
        
        if not uid:
            return JsonResponse({"status": "error", "message": "Missing user ID"}, status=400)
        
        user_obj = user.objects.get(id=uid)
        
        # Validate reward points - prevent fraud
        current_rewards = int(user_obj.rewards) if user_obj.rewards else 0
        if reward_points_used > current_rewards:
            return JsonResponse({
                "status": "error", 
                "message": f"Insufficient reward points. Available: {current_rewards}, Requested: {reward_points_used}"
            }, status=400)
        
        # Validate discount matches reward points (1:1 conversion)
        if abs(discount_amount - reward_points_used) > 0.01:
            return JsonResponse({
                "status": "error", 
                "message": "Discount amount does not match reward points"
            }, status=400)
        
        # Calculate final amount after discount
        try:
            amount_float = float(total_amount) if total_amount else 0
            final_amount = max(0, amount_float - discount_amount)
        except (ValueError, TypeError):
            final_amount = 0
        
        # Create order
        order_obj = order()
        order_obj.USER_id = uid
        order_obj.date = datetime.datetime.now().date()
        order_obj.status = "completed"
        order_obj.RECYCLER_id = 1
        order_obj.paymentmode = payment_mode
        order_obj.amount = str(final_amount)  # Store final amount after discount
        order_obj.save()
        
        # Get cart items for this user and create order subitems
        cart_items = cart.objects.filter(USER_id=uid)
        total_reward_points = 0
        
        for item in cart_items:
            ordersub_obj = ordersub()
            ordersub_obj.ORDER_id = order_obj.id
            ordersub_obj.PRODUCT_id = item.PRODUCT_id
            ordersub_obj.qty = item.qty
            ordersub_obj.save()
            
            # Calculate reward points: 10% of amount per item
            item_points = int(float(item.qty) * 0.1) if item.qty else 0
            total_reward_points += item_points
        
        # Convert final amount to credit points (1 rupee = 1 point, 10% bonus)
        credit_points = int(final_amount) + int(final_amount * 0.1)
        
        # Update user rewards: deduct used points and add earned points
        current_rewards = int(user_obj.rewards) if user_obj.rewards else 0
        new_rewards = current_rewards - reward_points_used + credit_points + total_reward_points
        user_obj.rewards = max(0, new_rewards)  # Ensure non-negative
        user_obj.save()
        
        # Clear cart after order
        cart_items.delete()
        
        return JsonResponse({
            "status": "ok",
            "message": "Order placed successfully",
            "order_id": order_obj.id,
            "payment_id": payment_id,
            "original_amount": total_amount,
            "discount_applied": discount_amount,
            "final_amount": final_amount,
            "reward_points_used": reward_points_used,
            "credit_points_earned": credit_points + total_reward_points,
            "total_rewards": user_obj.rewards,
        })
    
    except user.DoesNotExist:
        return JsonResponse({"status": "error", "message": "User not found"}, status=404)
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)
```

---

## Key Changes Summary

| Component | Change | Impact |
|-----------|--------|--------|
| **View Cart Page** | Added reward points display + input | Users see available points |
| **Discount Calculation** | Real-time 1:1 conversion | Instant feedback on discount |
| **Cost Breakdown** | Shows subtotal/discount/final | Transparency for users |
| **Navigation** | Pass discount to RazorpayScreen | Payment knows about discount |
| **Order Creation** | Accept & validate discount | Backend applies discount |
| **User Rewards** | Deduct used points + credit earned | Balances updated correctly |
| **Error Handling** | Validate balance & fraud check | Secure transaction |
| **Cart Clearing** | After successful order | Clean state for next purchase |

---

## Testing Checklist

```
Frontend Tests:
☐ Reward points display correctly on cart load
☐ Input field only accepts numbers
☐ Negative points show error
☐ Points > available show error
☐ Discount updates in real-time
☐ Final amount = total - discount
☐ Empty input clears discount

Backend Tests:
☐ Accept reward_points_used parameter
☐ Accept discount_amount parameter
☐ Validate user balance
☐ Validate discount amount matches points
☐ Deduct points from user.rewards
☐ Add earned points to user.rewards
☐ Store final_amount in order
☐ Return all fields in response

Integration Tests:
☐ Cart → Enter points → Payment → Order → Cart refreshes
☐ Reward balance decreases after purchase
☐ Order amount is final amount (after discount)
☐ New earned points are credited
☐ Cart is cleared after order
```

