import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/booking_model.dart';
import '../models/trip_model.dart';
import 'currency_service.dart';
import 'firebase_service.dart';

class BookingShareService {
  /// Returns a valid non-zero anchor rect required by iOS share sheet
  static Rect _getSharePositionOrigin() {
    final context = Get.context;
    if (context != null) {
      final size = MediaQuery.of(context).size;
      if (size.width > 0 && size.height > 0) {
        return Rect.fromLTWH(0, 0, size.width, size.height / 2);
      }
    }
    return const Rect.fromLTWH(0, 0, 100, 100);
  }

  static String _shortId(String id) {
    return id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  }

  /// Share booking details as text
  static Future<void> shareBookingDetails(BookingGroup bookingGroup) async {
    try {
      final shareText = _generateShareText(bookingGroup);

      await Share.share(
        shareText,
        subject:
            'Booking Details - ${bookingGroup.fromCity} to ${bookingGroup.destinationCity}',
        sharePositionOrigin: _getSharePositionOrigin(),
      );
    } catch (e) {
      throw Exception('Failed to share booking details: $e');
    }
  }

  /// Share trip details as text
  static Future<void> shareTripDetails(TripModel trip) async {
    try {
      final shareText = _generateShareTripText(trip);

      await Share.share(
        shareText,
        subject: 'Booking Details - ${trip.fromCity} to ${trip.destinationCity}',
        sharePositionOrigin: _getSharePositionOrigin(),
      );
    } catch (e) {
      throw Exception('Failed to share booking details: $e');
    }
  }

  /// Download ticket as PDF and open system share/save sheet
  static Future<void> downloadTicket(BookingGroup bookingGroup) async {
    try {
      // Generate PDF in temporary directory (no storage permission needed)
      final pdfFile = await _generateTicketPDF(bookingGroup);

      // Optional: Also save a copy to app Documents directory
      await _savePDFToDocuments(pdfFile, bookingGroup);

      // Share the PDF file so user can save it to Files / send it
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject:
            'Booking Ticket - ${bookingGroup.fromCity} to ${bookingGroup.destinationCity}',
        text: 'Your booking ticket is attached',
        sharePositionOrigin: _getSharePositionOrigin(),
      );
    } catch (e) {
      throw Exception('Failed to download ticket: $e');
    }
  }

  /// Save PDF to Documents directory
  static Future<void> _savePDFToDocuments(
    File pdfFile,
    BookingGroup bookingGroup,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'ticket_${bookingGroup.bookings.first.id}.pdf';
      final savedFile = File('${directory.path}/$fileName');

      await pdfFile.copy(savedFile.path);
      print('PDF saved to: ${savedFile.path}');
    } catch (e) {
      print('Failed to save PDF to documents: $e');
    }
  }

  /// Generate shareable text for booking
  static String _generateShareText(BookingGroup bookingGroup) {
    final booking = bookingGroup.bookings.first;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    final buffer = StringBuffer();

    buffer.writeln('🚗 *Booking Details*');
    buffer.writeln('');
    buffer.writeln(
        '📍 *Route:* ${bookingGroup.fromCity} to ${bookingGroup.destinationCity}');
    buffer.writeln('📅 *Date:* ${dateFormat.format(booking.tripDateTime)}');
    buffer.writeln('⏰ *Time:* ${timeFormat.format(booking.tripDateTime)}');
    buffer.writeln(
        '🚙 *Vehicle:* ${bookingGroup.vehicle.brand} ${bookingGroup.vehicle.model}');
    buffer.writeln(
        '🎫 *Seats:* ${bookingGroup.totalSeats} (${bookingGroup.bookings.map((b) => b.seatNumbers.join(', ')).join(', ')})');
    buffer.writeln(
        '💰 *Total Amount:* ${CurrencyService.instance.formatPrice(bookingGroup.totalPrice)}');
    buffer.writeln('📋 *Status:* ${booking.status.name.capitalizeFirst}');
    buffer.writeln('🆔 *Booking ID:* ${_shortId(booking.id)}');

    if (bookingGroup.hasMultipleSegments) {
      buffer.writeln('');
      buffer.writeln('🛣️ *Journey Segments:*');
      for (final segment in bookingGroup.segments) {
        buffer.writeln(
            '   • ${segment.fromPoint} to ${segment.toPoint} (${segment.vehicleType})');
      }
    }

    buffer.writeln('');
    buffer.writeln('Download the app to track your trip in real-time!');

    return buffer.toString();
  }

  /// Generate shareable text for trip
  static String _generateShareTripText(TripModel trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    final buffer = StringBuffer();

    buffer.writeln('🚗 *Trip Details*');
    buffer.writeln('');
    buffer.writeln('📍 *Route:* ${trip.fromCity} to ${trip.destinationCity}');
    buffer.writeln('📅 *Date:* ${dateFormat.format(trip.dateTime)}');
    buffer.writeln('⏰ *Time:* ${timeFormat.format(trip.dateTime)}');
    buffer.writeln(
        '🚙 *Vehicle:* ${trip.segments.first.vehicle?.brand} ${trip.segments.first.vehicle?.model}');
    buffer.writeln('🎫 *Seats:* ${trip.totalSeats}');
    buffer.writeln(
        '💰 *Total Amount:* ${CurrencyService.instance.formatPrice(trip.totalPrice)}');
    buffer.writeln('📋 *Status:* ${trip.status.capitalizeFirst}');
    buffer.writeln('🆔 *Trip ID:* ${_shortId(trip.id)}');

    if (trip.hasMultipleSegments) {
      buffer.writeln('');
      buffer.writeln('🛣️ *Journey Segments:*');
      for (final segment in trip.segments) {
        buffer.writeln(
            '   • ${segment.fromPoint} to ${segment.toPoint} (${segment.vehicleType})');
      }
    }

    buffer.writeln('');
    buffer.writeln('Download the app to track your trip in real-time!');

    return buffer.toString();
  }

  /// Generate PDF ticket with user information
  static Future<File> _generateTicketPDF(BookingGroup bookingGroup) async {
    final font = await _loadPdfFont();

    final userProfile = await FirebaseService.getUserProfile();
    final userName = userProfile?.fullName ?? 'Passenger';
    final userEmail = userProfile?.email ?? 'No email';

    final pdf = pw.Document();
    final booking = bookingGroup.bookings.first;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0694E3),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'BOOKING TICKET',
                      style: pw.TextStyle(
                        font: font,
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '${bookingGroup.fromCity} to ${bookingGroup.destinationCity}',
                      style: pw.TextStyle(
                        font: font,
                        color: PdfColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Passenger Information Section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  color: PdfColors.blue50,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PASSENGER INFORMATION',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Name', userName, font),
                              _buildDetailRow('Email', userEmail, font),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  'Booking ID', _shortId(booking.id), font),
                              _buildDetailRow('Status',
                                  booking.status.name.toUpperCase(), font),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Trip Details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            'Date', dateFormat.format(booking.tripDateTime), font),
                        _buildDetailRow(
                            'Time', timeFormat.format(booking.tripDateTime), font),
                        _buildDetailRow('From', bookingGroup.fromCity, font),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            'Vehicle',
                            '${bookingGroup.vehicle.brand} ${bookingGroup.vehicle.model}',
                            font),
                        _buildDetailRow(
                            'Seats', bookingGroup.totalSeats.toString(), font),
                        _buildDetailRow(
                            'To', bookingGroup.destinationCity, font),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Seat Details
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SEAT DETAILS',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: bookingGroup.bookings
                          .map(
                            (b) => pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey400),
                                borderRadius: const pw.BorderRadius.all(
                                    pw.Radius.circular(6)),
                              ),
                              child: pw.Column(
                                children: [
                                  pw.Text(
                                    'Seat ${b.seatNumbers.join(', ')}',
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 12,
                                    ),
                                  ),
                                  pw.Text(
                                    CurrencyService.instance
                                        .formatPriceWithCurrency(b.price),
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 10,
                                      color: PdfColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

              // Total Amount
              pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(top: 20),
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green300),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  color: PdfColors.green50,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL AMOUNT:',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                    pw.Text(
                      CurrencyService.instance
                          .formatPriceWithCurrency(bookingGroup.totalPrice),
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 30),
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Center(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Thank you for choosing our service!',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Present this ticket to the driver before boarding',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Elbabor_Ticket_${booking.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildDetailRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Future<pw.Font> _loadPdfFont() async {
    return pw.Font.courier();
  }
}
