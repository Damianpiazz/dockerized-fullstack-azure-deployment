"use client";

import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { Client, ClientFormData, clientService } from "@/services/clientService";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";

interface ClientFormProps {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
  client?: Client | null;
}

export default function ClientForm({
  open,
  onClose,
  onSuccess,
  client,
}: ClientFormProps) {
  const isEditing = !!client;

  const {
    register,
    handleSubmit,
    reset,
    setValue,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<ClientFormData>({
    defaultValues: {
      firstName: "",
      lastName: "",
      email: "",
      phone: "",
      document: "",
      address: "",
      isActive: true,
    },
  });

  const isActive = watch("isActive");

  useEffect(() => {
    if (client) {
      reset({
        firstName: client.firstName,
        lastName: client.lastName,
        email: client.email,
        phone: client.phone ?? "",
        document: client.document ?? "",
        address: client.address ?? "",
        isActive: client.isActive,
      });
    } else {
      reset({
        firstName: "",
        lastName: "",
        email: "",
        phone: "",
        document: "",
        address: "",
        isActive: true,
      });
    }
  }, [client, reset]);

  const onSubmit = async (data: ClientFormData) => {
    try {
      const payload = {
        ...data,
        phone: data.phone || undefined,
        document: data.document || undefined,
        address: data.address || undefined,
      };

      if (isEditing && client) {
        await clientService.update(client.id, payload);
      } else {
        await clientService.create(payload);
      }

      onSuccess();
      onClose();
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>
            {isEditing ? "Editar cliente" : "Nuevo cliente"}
          </DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1">
              <Label htmlFor="firstName">Nombre *</Label>
              <Input
                id="firstName"
                {...register("firstName", { required: "Requerido" })}
              />
              {errors.firstName && (
                <p className="text-sm text-red-500">{errors.firstName.message}</p>
              )}
            </div>

            <div className="space-y-1">
              <Label htmlFor="lastName">Apellido *</Label>
              <Input
                id="lastName"
                {...register("lastName", { required: "Requerido" })}
              />
              {errors.lastName && (
                <p className="text-sm text-red-500">{errors.lastName.message}</p>
              )}
            </div>
          </div>

          <div className="space-y-1">
            <Label htmlFor="email">Email *</Label>
            <Input
              id="email"
              type="email"
              {...register("email", {
                required: "Requerido",
                pattern: {
                  value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                  message: "Email inválido",
                },
              })}
            />
            {errors.email && (
              <p className="text-sm text-red-500">{errors.email.message}</p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1">
              <Label htmlFor="phone">Teléfono</Label>
              <Input id="phone" {...register("phone")} />
            </div>

            <div className="space-y-1">
              <Label htmlFor="document">Documento</Label>
              <Input id="document" {...register("document")} />
            </div>
          </div>

          <div className="space-y-1">
            <Label htmlFor="address">Dirección</Label>
            <Input id="address" {...register("address")} />
          </div>

          <div className="flex items-center gap-3">
            <Switch
              id="isActive"
              checked={isActive}
              onCheckedChange={(val) => setValue("isActive", val)}
            />
            <Label htmlFor="isActive">Cliente activo</Label>
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={onClose}>
              Cancelar
            </Button>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? "Guardando..." : isEditing ? "Actualizar" : "Crear"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}