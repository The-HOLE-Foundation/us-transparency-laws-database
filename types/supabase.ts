Initialising login role...
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.5"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      agencies: {
        Row: {
          agency_type: string | null
          contact_info: Json
          created_at: string
          foia_officer_email: string | null
          foia_officer_name: string | null
          foia_submission_url: string | null
          id: string
          jurisdiction_id: string
          name: string
          updated_at: string
        }
        Insert: {
          agency_type?: string | null
          contact_info?: Json
          created_at?: string
          foia_officer_email?: string | null
          foia_officer_name?: string | null
          foia_submission_url?: string | null
          id?: string
          jurisdiction_id: string
          name: string
          updated_at?: string
        }
        Update: {
          agency_type?: string | null
          contact_info?: Json
          created_at?: string
          foia_officer_email?: string | null
          foia_officer_name?: string | null
          foia_submission_url?: string | null
          id?: string
          jurisdiction_id?: string
          name?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "agencies_jurisdiction_id_fkey"
            columns: ["jurisdiction_id"]
            isOneToOne: false
            referencedRelation: "jurisdictions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "agencies_jurisdiction_id_fkey"
            columns: ["jurisdiction_id"]
            isOneToOne: false
            referencedRelation: "transparency_map_display"
            referencedColumns: ["jurisdiction_id"]
          },
        ]
      }
      agency_obligations: {
        Row: {
          additional_fields: Json
          annual_reporting_required: boolean
          business_hours_access: boolean
          created_at: string
          electronic_submission_accepted: boolean
          electronic_submission_required: string | null
          id: string
          public_liaison_required: boolean
          records_officer_required: boolean
          records_officer_title: string | null
          response_format_options: string | null
          transparency_law_id: string
          updated_at: string
        }
        Insert: {
          additional_fields?: Json
          annual_reporting_required?: boolean
          business_hours_access?: boolean
          created_at?: string
          electronic_submission_accepted?: boolean
          electronic_submission_required?: string | null
          id?: string
          public_liaison_required?: boolean
          records_officer_required?: boolean
          records_officer_title?: string | null
          response_format_options?: string | null
          transparency_law_id: string
          updated_at?: string
        }
        Update: {
          additional_fields?: Json
          annual_reporting_required?: boolean
          business_hours_access?: boolean
          created_at?: string
          electronic_submission_accepted?: boolean
          electronic_submission_required?: string | null
          id?: string
          public_liaison_required?: boolean
          records_officer_required?: boolean
          records_officer_title?: string | null
          response_format_options?: string | null
          transparency_law_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "agency_obligations_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_laws"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "agency_obligations_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_map_display"
            referencedColumns: ["transparency_law_id"]
          },
        ]
      }
      appeal_processes: {
        Row: {
          additional_fields: Json
          attorney_fees_cite: string | null
          attorney_fees_notes: string | null
          attorney_fees_recoverable: boolean
          created_at: string
          first_level: string | null
          first_level_cite: string | null
          first_level_deadline_days: number | null
          first_level_deadline_notes: string | null
          id: string
          second_level: string | null
          second_level_cite: string | null
          second_level_deadline_days: number | null
          second_level_deadline_notes: string | null
          transparency_law_id: string
          updated_at: string
        }
        Insert: {
          additional_fields?: Json
          attorney_fees_cite?: string | null
          attorney_fees_notes?: string | null
          attorney_fees_recoverable?: boolean
          created_at?: string
          first_level?: string | null
          first_level_cite?: string | null
          first_level_deadline_days?: number | null
          first_level_deadline_notes?: string | null
          id?: string
          second_level?: string | null
          second_level_cite?: string | null
          second_level_deadline_days?: number | null
          second_level_deadline_notes?: string | null
          transparency_law_id: string
          updated_at?: string
        }
        Update: {
          additional_fields?: Json
          attorney_fees_cite?: string | null
          attorney_fees_notes?: string | null
          attorney_fees_recoverable?: boolean
          created_at?: string
          first_level?: string | null
          first_level_cite?: string | null
          first_level_deadline_days?: number | null
          first_level_deadline_notes?: string | null
          id?: string
          second_level?: string | null
          second_level_cite?: string | null
          second_level_deadline_days?: number | null
          second_level_deadline_notes?: string | null
          transparency_law_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "appeal_processes_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_laws"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appeal_processes_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_map_display"
            referencedColumns: ["transparency_law_id"]
          },
        ]
      }
      exemptions: {
        Row: {
          category: string
          citation: string
          created_at: string
          description: string
          display_order: number
          id: string
          jurisdiction_code: string | null
          jurisdiction_name: string | null
          jurisdiction_slug: string | null
          scope: string
          subcategories: string | null
          transparency_law_id: string
          updated_at: string
        }
        Insert: {
          category: string
          citation: string
          created_at?: string
          description: string
          display_order?: number
          id?: string
          jurisdiction_code?: string | null
          jurisdiction_name?: string | null
          jurisdiction_slug?: string | null
          scope: string
          subcategories?: string | null
          transparency_law_id: string
          updated_at?: string
        }
        Update: {
          category?: string
          citation?: string
          created_at?: string
          description?: string
          display_order?: number
          id?: string
          jurisdiction_code?: string | null
          jurisdiction_name?: string | null
          jurisdiction_slug?: string | null
          scope?: string
          subcategories?: string | null
          transparency_law_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "exemptions_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: false
            referencedRelation: "transparency_laws"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "exemptions_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: false
            referencedRelation: "transparency_map_display"
            referencedColumns: ["transparency_law_id"]
          },
        ]
      }
      fee_structures: {
        Row: {
          additional_fields: Json
          copy_fee_cite: string | null
          copy_fee_notes: string | null
          copy_fee_per_page: number | null
          created_at: string
          electronic_fee: string | null
          fee_protection_notes: string | null
          fee_waiver_available: boolean
          fee_waiver_cite: string | null
          fee_waiver_criteria: string | null
          id: string
          search_fee: string | null
          search_fee_statutory_cite: string | null
          transparency_law_id: string
          updated_at: string
        }
        Insert: {
          additional_fields?: Json
          copy_fee_cite?: string | null
          copy_fee_notes?: string | null
          copy_fee_per_page?: number | null
          created_at?: string
          electronic_fee?: string | null
          fee_protection_notes?: string | null
          fee_waiver_available?: boolean
          fee_waiver_cite?: string | null
          fee_waiver_criteria?: string | null
          id?: string
          search_fee?: string | null
          search_fee_statutory_cite?: string | null
          transparency_law_id: string
          updated_at?: string
        }
        Update: {
          additional_fields?: Json
          copy_fee_cite?: string | null
          copy_fee_notes?: string | null
          copy_fee_per_page?: number | null
          created_at?: string
          electronic_fee?: string | null
          fee_protection_notes?: string | null
          fee_waiver_available?: boolean
          fee_waiver_cite?: string | null
          fee_waiver_criteria?: string | null
          id?: string
          search_fee?: string | null
          search_fee_statutory_cite?: string | null
          transparency_law_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fee_structures_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_laws"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fee_structures_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_map_display"
            referencedColumns: ["transparency_law_id"]
          },
        ]
      }
      jurisdictions: {
        Row: {
          created_at: string
          id: string
          jurisdiction_type: string
          name: string
          slug: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          jurisdiction_type: string
          name: string
          slug: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          jurisdiction_type?: string
          name?: string
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      oversight_bodies: {
        Row: {
          additional_fields: Json
          contact_info: string | null
          created_at: string
          id: string
          name: string
          oversight_url: string | null
          role: string
          transparency_law_id: string
          updated_at: string
        }
        Insert: {
          additional_fields?: Json
          contact_info?: string | null
          created_at?: string
          id?: string
          name: string
          oversight_url?: string | null
          role: string
          transparency_law_id: string
          updated_at?: string
        }
        Update: {
          additional_fields?: Json
          contact_info?: string | null
          created_at?: string
          id?: string
          name?: string
          oversight_url?: string | null
          role?: string
          transparency_law_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "oversight_bodies_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_laws"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "oversight_bodies_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_map_display"
            referencedColumns: ["transparency_law_id"]
          },
        ]
      }
      requester_requirements: {
        Row: {
          additional_fields: Json
          created_at: string
          id: string
          identification_required: boolean
          purpose_statement_required: boolean
          request_format_notes: string | null
          residency_requirement: boolean
          specific_format: string | null
          transparency_law_id: string
          updated_at: string
        }
        Insert: {
          additional_fields?: Json
          created_at?: string
          id?: string
          identification_required?: boolean
          purpose_statement_required?: boolean
          request_format_notes?: string | null
          residency_requirement?: boolean
          specific_format?: string | null
          transparency_law_id: string
          updated_at?: string
        }
        Update: {
          additional_fields?: Json
          created_at?: string
          id?: string
          identification_required?: boolean
          purpose_statement_required?: boolean
          request_format_notes?: string | null
          residency_requirement?: boolean
          specific_format?: string | null
          transparency_law_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "requester_requirements_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_laws"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "requester_requirements_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_map_display"
            referencedColumns: ["transparency_law_id"]
          },
        ]
      }
      response_requirements: {
        Row: {
          additional_fields: Json
          created_at: string
          extension_allowed: boolean
          extension_conditions: string | null
          extension_max_days: number | null
          final_response_time: number | null
          final_response_unit: string | null
          id: string
          initial_response_time: number | null
          initial_response_unit: string | null
          tolling_allowed: boolean
          tolling_notes: string | null
          transparency_law_id: string
          updated_at: string
        }
        Insert: {
          additional_fields?: Json
          created_at?: string
          extension_allowed?: boolean
          extension_conditions?: string | null
          extension_max_days?: number | null
          final_response_time?: number | null
          final_response_unit?: string | null
          id?: string
          initial_response_time?: number | null
          initial_response_unit?: string | null
          tolling_allowed?: boolean
          tolling_notes?: string | null
          transparency_law_id: string
          updated_at?: string
        }
        Update: {
          additional_fields?: Json
          created_at?: string
          extension_allowed?: boolean
          extension_conditions?: string | null
          extension_max_days?: number | null
          final_response_time?: number | null
          final_response_unit?: string | null
          id?: string
          initial_response_time?: number | null
          initial_response_unit?: string | null
          tolling_allowed?: boolean
          tolling_notes?: string | null
          transparency_law_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "response_requirements_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_laws"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "response_requirements_transparency_law_id_fkey"
            columns: ["transparency_law_id"]
            isOneToOne: true
            referencedRelation: "transparency_map_display"
            referencedColumns: ["transparency_law_id"]
          },
        ]
      }
      transparency_laws: {
        Row: {
          created_at: string
          effective_date: string | null
          id: string
          jurisdiction_id: string
          last_amended: string | null
          name: string
          official_resources: Json
          statute_citation: string
          updated_at: string
          validation_metadata: Json
        }
        Insert: {
          created_at?: string
          effective_date?: string | null
          id?: string
          jurisdiction_id: string
          last_amended?: string | null
          name: string
          official_resources?: Json
          statute_citation: string
          updated_at?: string
          validation_metadata?: Json
        }
        Update: {
          created_at?: string
          effective_date?: string | null
          id?: string
          jurisdiction_id?: string
          last_amended?: string | null
          name?: string
          official_resources?: Json
          statute_citation?: string
          updated_at?: string
          validation_metadata?: Json
        }
        Relationships: [
          {
            foreignKeyName: "transparency_laws_jurisdiction_id_fkey"
            columns: ["jurisdiction_id"]
            isOneToOne: true
            referencedRelation: "jurisdictions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "transparency_laws_jurisdiction_id_fkey"
            columns: ["jurisdiction_id"]
            isOneToOne: true
            referencedRelation: "transparency_map_display"
            referencedColumns: ["jurisdiction_id"]
          },
        ]
      }
    }
    Views: {
      transparency_map_display: {
        Row: {
          appeal_process: Json | null
          attorney_fees_available: boolean | null
          core_principle: string | null
          created_at: string | null
          effective_date: string | null
          exemption_categories: Json | null
          fee_structure: Json | null
          fee_waiver_available: boolean | null
          jurisdiction_code: string | null
          jurisdiction_id: string | null
          jurisdiction_name: string | null
          jurisdiction_type: string | null
          key_features_tags: string[] | null
          last_amended: string | null
          official_resources: Json | null
          oversight_body: Json | null
          primary_sources: string | null
          recent_changes_2024_2025: string | null
          response_timeline_days: number | null
          response_timeline_description: string | null
          response_timeline_extension: Json | null
          response_timeline_type: string | null
          statute_abbreviation: string | null
          statute_full_name: string | null
          transparency_law_id: string | null
          updated_at: string | null
          verification_date: string | null
          version: string | null
        }
        Relationships: []
      }
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const
