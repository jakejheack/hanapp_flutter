class ApiConfig {
  // IMPORTANT: Replace with the actual URL of your Hostinger API folder.
  // Example: "https://your_domain.com/api"
  // Make sure to use HTTPS in production!
  static const String baseUrl = "https://autosell.io/apiv2"; // Replace with your domain

  static const String registerEndpoint = "$baseUrl/register.php";
  static const String loginEndpoint = "$baseUrl/login.php";
  static const String verifyEmailEndpoint = "$baseUrl/verify_email.php";
  static const String uploadProfilePictureEndpoint = "$baseUrl/upload_profile_picture.php";
  static const String updateRoleEndpoint = "$baseUrl/update_role.php";

  // NEW Listing Endpoints
  static const String createListingEndpoint = "$baseUrl/create_listing.php";
  static const String getListingsEndpoint = "$baseUrl/get_listings.php";
  static const String getListingDetailsEndpoint = "$baseUrl/get_listing_details.php";
  static const String applyToListingEndpoint = "$baseUrl/apply_to_listing.php";
  static const String getApplicantsEndpoint = "$baseUrl/get_applicants.php";
  static const String deleteListingEndpoint = "$baseUrl/delete_listing.php";
  static const String completeListingEndpoint = "$baseUrl/complete_listing.php";
  // NEW User & Review Endpoints
  static const String getUserProfileEndpoint = "$baseUrl/get_user_profile.php";
  static const String submitReviewEndpoint = "$baseUrl/submit_review.php";
  static const String getUserReviewsEndpoint = "$baseUrl/get_user_reviews.php";

  // NEW Chat Endpoints (Simplified)
  static const String sendMessageEndpoint = "$baseUrl/send_message.php";
  static const String getMessagesEndpoint = "$baseUrl/get_messages.php";

 // static const String getConversationsEndpoint = "$baseUrl/chat/get_conversations.php"; // NEW
  // Notification Endpoints
  static const String getNotificationsEndpoint = "$baseUrl/notifications/get_notifications.php"; // NEW
  static const String markNotificationAsReadEndpoint = "$baseUrl/notifications/mark_read.php";
  //static const String updateApplicationStatusEndpoint = "$baseUrl/listings/update_application_status.php";
  
  // Favorite Endpoints
  static const String addFavoriteEndpoint = "$baseUrl/favorite/add_favorite_user.php";
  static const String removeFavoriteEndpoint = "$baseUrl/favorite/remove_favorite.php";
  static const String getFavoritesEndpoint = "$baseUrl/favorite/get_favorite.php";

  // users block
  static  const String blockUserEndpoint = "$baseUrl/user/block_user.php";
  static const String unblockUserEndpoint = "$baseUrl/user/unblock_user.php";
  static const String getBlockedUsersEndpoint = "$baseUrl/user/get_blocked_user.php";

  static const String createAsapListingEndpoint = "$baseUrl/asap_listings/create_asap_listing.php";

  static const String updateUserProfileEndpoint = "$baseUrl/update_profile.php";

  // Balance Endpoints (Placeholder for now, actual implementation would need backend)
  static const String getBalanceEndpoint = "$baseUrl/balance/get_balance.php"; // NEW
  static const String getTransactionsEndpoint = "$baseUrl/balance/get_transactions.php"; // NEW
  static const String cashInEndpoint = "$baseUrl/balance/cash_in.php";

  static const String updateListingEndpoint = "$baseUrl/update_listing.php"; // NEW
  static const String updateApplicationStatusEndpoint = "$baseUrl/update_application_status.php";

  static const String getConversationsEndpoint = "$baseUrl/get_conversations.php"; // NEW: Get conversations

  static const String getReviewsForUserEndpoint = "$baseUrl/rating/get_reviews_for_user.php"; // NEW: Endpoint for reviews
  static const String getApplicationDetailsEndpoint = "$baseUrl/get_application_details.php"; // NEW: Endpoint for application details
}